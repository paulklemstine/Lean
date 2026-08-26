import Mathlib
import Novelty.ZeroFitDialU64
import Novelty.ZeroFitDialExactBitlen48

/-!
# The relation-rate half of the zero-fit dial: coarse binary responses at exact bitlen 48

## Research context (FACT round-56 #1, exp 526, `CELL-CLOSED-DIAL-HOLDS-UNIF-48`)

The measurement under study reports a Spearman rank correlation between the
*zero-count statistic* `T` (number of trailing binary zeros, i.e. the 2-adic
valuation) and a downstream **relation rate**, on uniform draws of exact bitlen
48:

* seeds 20261110/11/12 give `0.7192 / 0.7202 / 0.7198`;
* `T` beats the popcount ("count") baseline by `+0.098` to `+0.145` everywhere;
* the **mean relation rate is `12.5 %`** — the "unstarved" regime.

Every previous catalog file on the dial (`Novelty.ZeroFitDialU64`,
`Novelty.ZeroFitDialExactBitlen48`, `MachineLearning.ZeroFitDialUnif52`, …)
models the *response* as a ranking that **refines** the tie blocks of `T`; the
resulting ceiling is the `6/7` tie-attenuation law.  The new coordinate of this
cell is the response itself: a *rate* of `12.5 %` is a coarse, essentially
two-valued object, and a coarse response obeys a completely different ceiling.
This file supplies that theory.

## Main results

* `massR_closed`, `massR_total` — the centred rank mass of a tie profile.
* `selMass`, `selMass_append`, `selMass_add_compl` — the centred rank mass
  carried by an arbitrary *selection* (a binary response choosing `sⱼ ≤ mⱼ`
  observations out of block `j`).
* `selMass_le_massR_top` — **greedy optimality**: among all binary responses of
  a given rate whose count matches a block boundary, the top-filling response
  maximises the centred cross moment.  (Two monotonicity bounds and a counting
  identity; no rearrangement machinery needed.)
* `covBin_eq`, `varBin_eq` — the exact centred cross moment and variance of a
  binary (Bernoulli) response against the midranks of a tied statistic:
  `Cov = (n/2)·selMass` and `Var = n·n₁·n₀/4`.
* `spearmanSqBin_le_varBin_div_ssR` — **the coarse-response ceiling**
  `ρ² ≤ n·K·(n-K) / (4·ssR)`, the exact analogue of the tie-attenuation law for
  a two-valued response splitting the sample at rank position `K`.
* `dyadic_binary_ceiling` — for the 2-adic profile the ceiling is the
  **rate parabola** `ρ² = (7/2)·p·(1-p)·n³/(n³-1)` at rate `p = 2^{-t}`.
* `coarse_beats_refining_at_half` — the `6/7` ceiling is *not* universal: a
  balanced binary response can reach `7/8 > 6/7`.  Coarsening the response can
  *raise* the attainable dial.
* `relation_response_not_binary` — **the payload**.  At exact bitlen 48 and
  relation rate `12.5 %` the coarse ceiling is `(49/128)·(1 + 1/(2¹⁴¹-1))
  ≈ 0.3828`, i.e. `ρ ≤ 7/(8√2) ≈ 0.6187`, strictly below every recorded seed
  (`0.7192² ≈ 0.5172`).  Hence the measured relation rate cannot be a
  single-trial indicator: the response must be genuinely graded.
* `binary_model_needs_double_rate` — quantitatively: a binary response at any
  dyadic rate `2^{-t} ≤ 1/8` is excluded, so a binary explanation of the dial
  would need a rate of at least `25 %`, twice the recorded `12.5 %`.
* `binary_ceiling_inversion_reversal` — **the tie-headroom inversion reverses
  under coarse responses.**  `Novelty.ZeroFitDialExactBitlen48` showed that at
  exact bitlen 48 the popcount baseline has strictly more *refining* headroom
  than `T`.  Because the coarse ceiling is antitone in the between-block
  variance, the ordering flips for a rate response: at every aligned rate the
  count baseline's coarse ceiling is strictly *below* `T`'s.  The recorded
  advantage `+0.098 … +0.145` of `T` over count is thus in the direction the
  coarse theory predicts.
* `round56_*` — the recorded round-56 numbers checked against the theory.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64
open Catalog.Novelty.ZeroFitDialExactBitlen48
open Catalog.MachineLearning.ZeroFitDialUnif52

namespace Catalog.Pythagorean.ZeroFitDialRelationRate48

/-! ## 0. Powers of two -/

lemma cube_two_pow_ge (b k : ℕ) (hb : k ≤ b) : ((8 : ℚ) ^ k) ≤ ((2 : ℚ) ^ b) ^ 3 := by
  rw [pow_two_cube]
  exact pow_le_pow_right₀ (by norm_num) hb

lemma two_pow_ge (b k : ℕ) (hb : k ≤ b) : ((2 : ℚ) ^ k) ≤ (2 : ℚ) ^ b :=
  pow_le_pow_right₀ (by norm_num) hb

/-! ## 1. Centred rank mass of a tie profile

A *tie profile* is the list `L = [m₀, m₁, …]` of block sizes of the tied statistic `T`,
in increasing order of the `T`-value.  Block `j` occupies rank positions
`Cⱼ+1, …, Cⱼ+mⱼ` (with `Cⱼ` the prefix sum) and carries the midrank
`rⱼ = Cⱼ + (mⱼ+1)/2`. -/

/-- Centred rank mass `Σⱼ mⱼ (rⱼ - mu)` of a profile whose first block starts after
rank offset `c`. -/
def massR (mu : ℚ) : List ℕ → ℚ → ℚ
  | [], _ => 0
  | m :: L, c => (m : ℚ) * ((c + ((m : ℚ) + 1) / 2) - mu) + massR mu L (c + m)

/-- Closed form: the midrank mass equals the raw rank mass of the same observations. -/
lemma massR_closed (mu : ℚ) (L : List ℕ) (c : ℚ) :
    massR mu L c = (L.sum : ℚ) * (c + ((L.sum : ℚ) + 1) / 2 - mu) := by
  induction L generalizing c with
  | nil => simp [massR]
  | cons m L ih =>
      rw [massR, ih, List.sum_cons, Nat.cast_add]
      ring

/-- Centred against the grand mean the total mass vanishes. -/
lemma massR_total (L : List ℕ) : massR (gmean L) L 0 = 0 := by
  rw [massR_closed, gmean]; ring

/-! ## 2. Selections: arbitrary binary responses -/

/-- Centred rank mass carried by a *selection*: the response is `1` on `sⱼ` of the `mⱼ`
observations of block `j` (which ones does not matter, midranks are constant on blocks). -/
def selMass (mu : ℚ) : List ℕ → List ℕ → ℚ → ℚ
  | [], _, _ => 0
  | _ :: _, [], _ => 0
  | m :: L, k :: s, c => (k : ℚ) * ((c + ((m : ℚ) + 1) / 2) - mu) + selMass mu L s (c + m)

lemma selMass_self (mu : ℚ) (L : List ℕ) (c : ℚ) : selMass mu L L c = massR mu L c := by
  induction L generalizing c with
  | nil => rfl
  | cons m L ih => rw [selMass, massR, ih]

/-- Splitting a selection at a block boundary. -/
lemma selMass_append (mu : ℚ) (L₁ s₁ L₂ s₂ : List ℕ) (c : ℚ) (h : s₁.length = L₁.length) :
    selMass mu (L₁ ++ L₂) (s₁ ++ s₂) c
      = selMass mu L₁ s₁ c + selMass mu L₂ s₂ (c + (L₁.sum : ℚ)) := by
  induction L₁ generalizing s₁ c with
  | nil =>
      cases s₁ with
      | nil => simp [selMass]
      | cons k s => simp at h
  | cons m L₁ ih =>
      cases s₁ with
      | nil => simp at h
      | cons k s₁ =>
          have hlen : s₁.length = L₁.length := by simpa using h
          have harg : c + (m : ℚ) + (L₁.sum : ℚ) = c + (((m :: L₁).sum : ℕ) : ℚ) := by
            rw [List.sum_cons, Nat.cast_add]; ring
          simp only [List.cons_append, selMass]
          rw [ih s₁ (c + m) hlen, harg]
          ring

/-- The pointwise complement of a selection is a selection. -/
lemma forall₂_zipWith_sub {s L : List ℕ} (h : List.Forall₂ (· ≤ ·) s L) :
    List.Forall₂ (· ≤ ·) (List.zipWith (· - ·) L s) L := by
  induction h with
  | nil => simp
  | @cons k m s L hkm _ ih => simpa using List.Forall₂.cons (Nat.sub_le m k) ih

/-- Appending selections. -/
lemma forall₂_append {s₁ L₁ s₂ L₂ : List ℕ} (h₁ : List.Forall₂ (· ≤ ·) s₁ L₁)
    (h₂ : List.Forall₂ (· ≤ ·) s₂ L₂) : List.Forall₂ (· ≤ ·) (s₁ ++ s₂) (L₁ ++ L₂) := by
  induction h₁ with
  | nil => simpa using h₂
  | @cons k m s L hkm _ ih => simpa using List.Forall₂.cons hkm ih

/-- The complement of a selection selects the complementary count. -/
lemma sum_zipWith_sub {s L : List ℕ} (h : List.Forall₂ (· ≤ ·) s L) :
    (((List.zipWith (· - ·) L s).sum : ℕ) : ℚ) = (L.sum : ℚ) - (s.sum : ℚ) := by
  induction h with
  | nil => simp
  | @cons k m s L hkm _ ih =>
      rw [List.zipWith_cons_cons, List.sum_cons, List.sum_cons, List.sum_cons, Nat.cast_add,
        Nat.cast_add, Nat.cast_add, Nat.cast_sub hkm, ih]
      ring

/-- A selection and its complement together carry the whole mass. -/
lemma selMass_add_compl {s L : List ℕ} (h : List.Forall₂ (· ≤ ·) s L) (mu c : ℚ) :
    selMass mu L s c + selMass mu L (List.zipWith (· - ·) L s) c = massR mu L c := by
  induction h generalizing c with
  | nil => simp [selMass, massR]
  | @cons k m s L hkm _ ih =>
      simp only [List.zipWith_cons_cons, selMass, massR]
      rw [Nat.cast_sub hkm, ← ih (c + m)]
      ring

/-- **Below the boundary.**  A selection confined to blocks that finish before rank `W`
carries at most `(number selected)·(W - mu)`. -/
lemma selMass_le_upper {s L : List ℕ} (h : List.Forall₂ (· ≤ ·) s L) (mu W c : ℚ)
    (hend : c + (L.sum : ℚ) ≤ W) : selMass mu L s c ≤ (s.sum : ℚ) * (W - mu) := by
  induction h generalizing c with
  | nil => simp [selMass]
  | @cons k m s L hkm _ ih =>
      rw [List.sum_cons, Nat.cast_add] at hend
      have hLsum : (0 : ℚ) ≤ (L.sum : ℚ) := by positivity
      have hIH := ih (c + m) (by linarith)
      have hterm : (k : ℚ) * ((c + ((m : ℚ) + 1) / 2) - mu) ≤ (k : ℚ) * (W - mu) := by
        rcases Nat.eq_zero_or_pos k with hk | hk
        · simp [hk]
        · have hm : 1 ≤ m := le_trans hk hkm
          have hm1 : (1 : ℚ) ≤ (m : ℚ) := by exact_mod_cast hm
          have hk0 : (0 : ℚ) ≤ (k : ℚ) := by positivity
          have hcm : c + ((m : ℚ) + 1) / 2 ≤ W := by linarith
          nlinarith
      rw [selMass, List.sum_cons, Nat.cast_add]
      linarith

/-- **Above the boundary.**  A selection confined to blocks that start at or after rank `W`
carries at least `(number selected)·(W - mu)`. -/
lemma lower_le_selMass {s L : List ℕ} (h : List.Forall₂ (· ≤ ·) s L) (mu W c : ℚ)
    (hstart : W ≤ c) : (s.sum : ℚ) * (W - mu) ≤ selMass mu L s c := by
  induction h generalizing c with
  | nil => simp [selMass]
  | @cons k m s L hkm _ ih =>
      have hm0 : (0 : ℚ) ≤ (m : ℚ) := by positivity
      have hIH := ih (c + m) (by linarith)
      have hterm : (k : ℚ) * (W - mu) ≤ (k : ℚ) * ((c + ((m : ℚ) + 1) / 2) - mu) := by
        have hk0 : (0 : ℚ) ≤ (k : ℚ) := by positivity
        nlinarith
      rw [selMass, List.sum_cons, Nat.cast_add]
      linarith

/-- **Greedy optimality of the top-filling response.**  If a binary response selects
exactly as many observations as the top blocks `L₂` contain, then its centred cross mass
is at most that of the response which selects precisely those top blocks.

The proof is the two-line exchange bound: everything selected below the boundary is worth
at most the boundary rank, everything left unselected above the boundary is worth at least
the boundary rank, and the two counts agree. -/
theorem selMass_le_massR_top {L₁ L₂ s₁ s₂ : List ℕ} (mu : ℚ)
    (h₁ : List.Forall₂ (· ≤ ·) s₁ L₁) (h₂ : List.Forall₂ (· ≤ ·) s₂ L₂)
    (hcount : (s₁.sum : ℚ) + (s₂.sum : ℚ) = (L₂.sum : ℚ)) :
    selMass mu (L₁ ++ L₂) (s₁ ++ s₂) 0 ≤ massR mu L₂ (L₁.sum : ℚ) := by
  have hsplit := selMass_append mu L₁ s₁ L₂ s₂ 0 h₁.length_eq
  rw [zero_add] at hsplit
  have hP : selMass mu L₁ s₁ 0 ≤ (s₁.sum : ℚ) * ((L₁.sum : ℚ) - mu) :=
    selMass_le_upper h₁ mu (L₁.sum : ℚ) 0 (by simp)
  have hcompl := selMass_add_compl h₂ mu (L₁.sum : ℚ)
  have hlow : (((List.zipWith (· - ·) L₂ s₂).sum : ℕ) : ℚ) * ((L₁.sum : ℚ) - mu)
      ≤ selMass mu L₂ (List.zipWith (· - ·) L₂ s₂) (L₁.sum : ℚ) :=
    lower_le_selMass (forall₂_zipWith_sub h₂) mu (L₁.sum : ℚ) (L₁.sum : ℚ) (le_refl _)
  have hzip := sum_zipWith_sub h₂
  rw [hsplit]
  rw [hzip] at hlow
  have hEq : (s₁.sum : ℚ) * ((L₁.sum : ℚ) - mu)
      = ((L₂.sum : ℚ) - (s₂.sum : ℚ)) * ((L₁.sum : ℚ) - mu) := by
    rw [show (s₁.sum : ℚ) = (L₂.sum : ℚ) - (s₂.sum : ℚ) by linarith]
  linarith

/-! ## 3. The coarse (binary) response and its exact ceiling

A binary response takes two values; after midranking it takes the value `(n₀+1)/2` on the
`n₀` observations where it is `0` and `n₀ + (n₁+1)/2` on the `n₁` observations where it
is `1`. -/

/-- Midrank of the observations where the binary response is `1`. -/
def onesMid (L s : List ℕ) : ℚ := ((L.sum : ℚ) - (s.sum : ℚ)) + ((s.sum : ℚ) + 1) / 2

/-- Midrank of the observations where the binary response is `0`. -/
def zerosMid (L s : List ℕ) : ℚ := (((L.sum : ℚ) - (s.sum : ℚ)) + 1) / 2

/-- Centred cross moment `Σᵢ (Rᵢ - μ)(Sᵢ - μ)` of the midranks of the tied statistic
against a binary response which is `1` on the selection `s`. -/
def covBin (L s : List ℕ) : ℚ :=
  (onesMid L s - gmean L) * selMass (gmean L) L s 0
    + (zerosMid L s - gmean L) * selMass (gmean L) L (List.zipWith (· - ·) L s) 0

/-- Centred sum of squares `Σᵢ (Sᵢ - μ)²` of the binary response's midranks. -/
def varBin (L s : List ℕ) : ℚ :=
  (s.sum : ℚ) * (onesMid L s - gmean L) ^ 2
    + ((L.sum : ℚ) - (s.sum : ℚ)) * (zerosMid L s - gmean L) ^ 2

/-- `Var S = n·n₁·n₀/4`. -/
lemma varBin_eq (L s : List ℕ) :
    varBin L s = (L.sum : ℚ) * (s.sum : ℚ) * ((L.sum : ℚ) - (s.sum : ℚ)) / 4 := by
  unfold varBin onesMid zerosMid gmean
  ring

/-- **Cross moment of a coarse response.**  `Cov = (n/2)·selMass`: only the centred rank
mass of the selected observations matters. -/
theorem covBin_eq {s L : List ℕ} (h : List.Forall₂ (· ≤ ·) s L) :
    covBin L s = ((L.sum : ℚ) / 2) * selMass (gmean L) L s 0 := by
  have htot := selMass_add_compl h (gmean L) 0
  rw [massR_total] at htot
  have hc : selMass (gmean L) L (List.zipWith (· - ·) L s) 0 = -selMass (gmean L) L s 0 := by
    linarith
  rw [covBin, hc, onesMid, zerosMid, gmean]
  ring

/-- Squared Spearman coefficient between a tied statistic with profile `L` and a binary
response which is `1` exactly on the selection `s`. -/
def spearmanSqBin (L s : List ℕ) : ℚ := covBin L s ^ 2 / (ssR (gmean L) L 0 * varBin L s)

/-- **Coarse-response ceiling.**  For a binary response whose `1`s number exactly the top
`n - K` observations (`K = L₁.sum` a block boundary), the squared Spearman coefficient
against the tied statistic is at most `n·K·(n-K)/(4·ssR)`.

This is the exact analogue of the tie-attenuation law for a *two-valued* response: the
attenuation is now governed by the response's own variance, not by the ties of `T`. -/
theorem spearmanSqBin_le_varBin_div_ssR {L₁ L₂ s₁ s₂ : List ℕ}
    (h₁ : List.Forall₂ (· ≤ ·) s₁ L₁) (h₂ : List.Forall₂ (· ≤ ·) s₂ L₂)
    (hcount : (s₁.sum : ℚ) + (s₂.sum : ℚ) = (L₂.sum : ℚ))
    (hK : 0 < (L₁.sum : ℚ)) (hK' : 0 < (L₂.sum : ℚ))
    (hssR : 0 < ssR (gmean (L₁ ++ L₂)) (L₁ ++ L₂) 0)
    (hcov : 0 ≤ covBin (L₁ ++ L₂) (s₁ ++ s₂)) :
    spearmanSqBin (L₁ ++ L₂) (s₁ ++ s₂)
      ≤ (((L₁ ++ L₂).sum : ℚ)) * (L₁.sum : ℚ) * (L₂.sum : ℚ)
          / (4 * ssR (gmean (L₁ ++ L₂)) (L₁ ++ L₂) 0) := by
  set L : List ℕ := L₁ ++ L₂ with hLdef
  have hfa : List.Forall₂ (· ≤ ·) (s₁ ++ s₂) L := forall₂_append h₁ h₂
  have hn : (L.sum : ℚ) = (L₁.sum : ℚ) + (L₂.sum : ℚ) := by
    rw [hLdef, List.sum_append, Nat.cast_add]
  have hs : (((s₁ ++ s₂).sum : ℕ) : ℚ) = (L₂.sum : ℚ) := by
    rw [List.sum_append, Nat.cast_add]; linarith [hcount]
  have hvar : varBin L (s₁ ++ s₂) = (L.sum : ℚ) * (L₁.sum : ℚ) * (L₂.sum : ℚ) / 4 := by
    rw [varBin_eq, hs, hn]; ring
  have hnpos : (0 : ℚ) < (L.sum : ℚ) := by rw [hn]; linarith
  have hvarpos : 0 < varBin L (s₁ ++ s₂) := by rw [hvar]; positivity
  have hmax : selMass (gmean L) L (s₁ ++ s₂) 0 ≤ massR (gmean L) L₂ (L₁.sum : ℚ) :=
    selMass_le_massR_top (gmean L) h₁ h₂ hcount
  have htop : massR (gmean L) L₂ (L₁.sum : ℚ) = (L₂.sum : ℚ) * (L₁.sum : ℚ) / 2 := by
    rw [massR_closed, gmean, hn]; ring
  have hcovle : covBin L (s₁ ++ s₂) ≤ varBin L (s₁ ++ s₂) := by
    have h1 : selMass (gmean L) L (s₁ ++ s₂) 0 ≤ (L₂.sum : ℚ) * (L₁.sum : ℚ) / 2 := by
      rw [← htop]; exact hmax
    have h2 := mul_le_mul_of_nonneg_left h1 (by linarith : (0 : ℚ) ≤ (L.sum : ℚ) / 2)
    rw [covBin_eq hfa, hvar]
    linarith
  have hsq : covBin L (s₁ ++ s₂) ^ 2 ≤ varBin L (s₁ ++ s₂) ^ 2 := by nlinarith
  have hdenpos : 0 < ssR (gmean L) L 0 * varBin L (s₁ ++ s₂) := by positivity
  have hstep : spearmanSqBin L (s₁ ++ s₂)
      ≤ varBin L (s₁ ++ s₂) ^ 2 / (ssR (gmean L) L 0 * varBin L (s₁ ++ s₂)) := by
    rw [spearmanSqBin]
    gcongr
  refine le_trans hstep (le_of_eq ?_)
  rw [hvar]
  field_simp

/-! ### The ceiling is attained: the top-filling response -/

lemma selMass_replicate_zero (mu : ℚ) (L : List ℕ) (c : ℚ) :
    selMass mu L (List.replicate L.length 0) c = 0 := by
  induction L generalizing c with
  | nil => rfl
  | cons m L ih => rw [List.length_cons, List.replicate_succ, selMass, ih]; ring

lemma forall₂_replicate_zero (L : List ℕ) :
    List.Forall₂ (· ≤ ·) (List.replicate L.length 0) L := by
  induction L with
  | nil => simp
  | cons m L ih =>
      rw [List.length_cons, List.replicate_succ]
      exact List.Forall₂.cons (Nat.zero_le m) ih

lemma forall₂_self (L : List ℕ) : List.Forall₂ (· ≤ ·) L L := by
  induction L with
  | nil => simp
  | cons m L ih => exact List.Forall₂.cons (le_refl m) ih

/-- **The coarse ceiling is attained.**  The top-filling response — `1` exactly on the blocks
of `L₂` — realises `ρ² = n·K·(n-K)/(4·ssR)`, so the bound of
`spearmanSqBin_le_varBin_div_ssR` is sharp and the hypotheses there are satisfiable. -/
theorem aligned_response_attains_ceiling (L₁ L₂ : List ℕ)
    (hK : 0 < (L₁.sum : ℚ)) (hK' : 0 < (L₂.sum : ℚ))
    (hssR : 0 < ssR (gmean (L₁ ++ L₂)) (L₁ ++ L₂) 0) :
    spearmanSqBin (L₁ ++ L₂) (List.replicate L₁.length 0 ++ L₂)
      = (((L₁ ++ L₂).sum : ℚ)) * (L₁.sum : ℚ) * (L₂.sum : ℚ)
          / (4 * ssR (gmean (L₁ ++ L₂)) (L₁ ++ L₂) 0) := by
  set L : List ℕ := L₁ ++ L₂ with hLdef
  set s : List ℕ := List.replicate L₁.length 0 ++ L₂ with hsdef
  have hfa : List.Forall₂ (· ≤ ·) s L := forall₂_append (forall₂_replicate_zero L₁) (forall₂_self L₂)
  have hn : (L.sum : ℚ) = (L₁.sum : ℚ) + (L₂.sum : ℚ) := by
    rw [hLdef, List.sum_append, Nat.cast_add]
  have hssum : ((s.sum : ℕ) : ℚ) = (L₂.sum : ℚ) := by
    rw [hsdef, List.sum_append, Nat.cast_add, List.sum_replicate]
    simp
  have hsel : selMass (gmean L) L s 0 = (L₂.sum : ℚ) * (L₁.sum : ℚ) / 2 := by
    rw [hLdef, hsdef,
      selMass_append (gmean L) L₁ (List.replicate L₁.length 0) L₂ L₂ 0 (by simp),
      selMass_replicate_zero, selMass_self, zero_add, zero_add, massR_closed, gmean]
    rw [hn]
    ring
  have hvar : varBin L s = (L.sum : ℚ) * (L₁.sum : ℚ) * (L₂.sum : ℚ) / 4 := by
    rw [varBin_eq, hssum, hn]; ring
  have hnpos : (0 : ℚ) < (L.sum : ℚ) := by rw [hn]; linarith
  have hvarpos : 0 < varBin L s := by rw [hvar]; positivity
  have hcov : covBin L s = varBin L s := by
    rw [covBin_eq hfa, hsel, hvar, hn]; ring
  rw [spearmanSqBin, hcov, hvar]
  field_simp

/-! ## 4. The dyadic profile: the rate parabola -/

/-- The between-block sum of squares of the 2-adic profile: `ssR = (n³-1)/14`. -/
theorem ssR_dyadic (b : ℕ) (hb : 1 ≤ b) :
    ssR (gmean (dyadicBlocks b)) (dyadicBlocks b) 0 = (((2 : ℚ) ^ b) ^ 3 - 1) / 14 := by
  have hsum : (dyadicBlocks b).sum = 2 ^ b := dyadicBlocks_sum b
  have hx : (2 : ℚ) ≤ (2 : ℚ) ^ b := by
    calc (2 : ℚ) = 2 ^ 1 := (pow_one 2).symm
      _ ≤ 2 ^ b := two_pow_ge b 1 hb
  have hcast : (((dyadicBlocks b).sum : ℕ) : ℚ) = (2 : ℚ) ^ b := by rw [hsum]; push_cast; ring
  have hssS : ssS (gmean (dyadicBlocks b)) (dyadicBlocks b) 0
      = (((2 : ℚ) ^ b) ^ 3 - (2 : ℚ) ^ b) / 12 := by
    rw [ssS_total, hcast]
  have hcube := cube_sub_self_pos hx
  have hssSpos : 0 < ssS (gmean (dyadicBlocks b)) (dyadicBlocks b) 0 := by
    rw [hssS]; linarith
  have hsq := dyadic_spearmanSq b hb
  rw [spearmanSq, div_eq_iff (ne_of_gt hssSpos)] at hsq
  rw [hsq, hssS]
  have h1 : (2 : ℚ) ^ b ≠ 0 := by positivity
  have h2 : (2 : ℚ) ^ b + 1 ≠ 0 := by positivity
  field_simp
  ring

/-- The prefix sums of the 2-adic profile are the dyadic boundaries `2^b - 2^{b-t}`. -/
lemma dyadic_take_sum (b t : ℕ) (ht : t ≤ b) :
    ((dyadicBlocks b).take t).sum + 2 ^ (b - t) = 2 ^ b := by
  induction t generalizing b with
  | zero => simp
  | succ t ih =>
      obtain ⟨b', rfl⟩ : ∃ b', b = b' + 1 := ⟨b - 1, by omega⟩
      have htb : t ≤ b' := by omega
      have hd : dyadicBlocks (b' + 1) = 2 ^ b' :: dyadicBlocks b' := rfl
      have hrec := ih b' htb
      have hidx : b' + 1 - (t + 1) = b' - t := by omega
      have hpow : 2 ^ (b' + 1) = 2 ^ b' + 2 ^ b' := by ring
      rw [hd, List.take_succ_cons, List.sum_cons, hidx]
      omega

/-- The suffix sums of the 2-adic profile. -/
lemma dyadic_drop_sum (b t : ℕ) (ht : t ≤ b) : ((dyadicBlocks b).drop t).sum = 2 ^ (b - t) := by
  have hsplit : ((dyadicBlocks b).take t).sum + ((dyadicBlocks b).drop t).sum
      = (dyadicBlocks b).sum := by
    rw [← List.sum_append, List.take_append_drop]
  have h1 := dyadic_take_sum b t ht
  have h2 := dyadicBlocks_sum b
  omega

/-- **The rate parabola.**  For the 2-adic tie profile at bitlen `b`, the coarse ceiling at
the dyadic rate `p = 2^{-t}` is `ρ² = (7/2)·p·(1-p)·n³/(n³-1)`, `n = 2^b`. -/
theorem dyadic_binary_ceiling (b t : ℕ) (hb : 1 ≤ b) (ht : t ≤ b) :
    ((dyadicBlocks b).sum : ℚ) * (((dyadicBlocks b).take t).sum : ℚ)
        * (((dyadicBlocks b).drop t).sum : ℚ)
        / (4 * ssR (gmean (dyadicBlocks b)) (dyadicBlocks b) 0)
      = (7 / 2) * (1 / (2 : ℚ) ^ t) * (1 - 1 / (2 : ℚ) ^ t)
          * (((2 : ℚ) ^ b) ^ 3 / (((2 : ℚ) ^ b) ^ 3 - 1)) := by
  have hpow : (2 : ℚ) ^ t * (2 : ℚ) ^ (b - t) = (2 : ℚ) ^ b := by
    rw [← pow_add]; congr 1; omega
  have hx : (2 : ℚ) ≤ (2 : ℚ) ^ b := by
    calc (2 : ℚ) = 2 ^ 1 := (pow_one 2).symm
      _ ≤ 2 ^ b := two_pow_ge b 1 hb
  have h8 : (8 : ℚ) ≤ ((2 : ℚ) ^ b) ^ 3 := by
    have := cube_two_pow_ge b 1 hb
    simpa using this
  have hsum : (((dyadicBlocks b).sum : ℕ) : ℚ) = (2 : ℚ) ^ b := by
    rw [dyadicBlocks_sum]; push_cast; ring
  have hdrop : ((((dyadicBlocks b).drop t).sum : ℕ) : ℚ) = (2 : ℚ) ^ (b - t) := by
    rw [dyadic_drop_sum b t ht]; push_cast; ring
  have htake : ((((dyadicBlocks b).take t).sum : ℕ) : ℚ) = (2 : ℚ) ^ b - (2 : ℚ) ^ (b - t) := by
    have hnat := dyadic_take_sum b t ht
    have hq : ((((dyadicBlocks b).take t).sum : ℕ) : ℚ) + (2 : ℚ) ^ (b - t) = (2 : ℚ) ^ b := by
      exact_mod_cast congrArg (fun k : ℕ => (k : ℚ)) hnat
    linarith
  have h3 : ((2 : ℚ) ^ b) ^ 3 - 1 ≠ 0 := by intro hcon; linarith
  rw [hsum, hdrop, htake, ssR_dyadic b hb, ← hpow] at *
  have h2t : (2 : ℚ) ^ t ≠ 0 := by positivity
  have hbt : (2 : ℚ) ^ (b - t) ≠ 0 := by positivity
  field_simp
  ring

/-! ## 5. The round-56 measurement -/

/-- Seed 20261110. -/
def seedA : ℚ := 7192 / 10000
/-- Seed 20261111. -/
def seedB : ℚ := 7202 / 10000
/-- Seed 20261112. -/
def seedC : ℚ := 7198 / 10000
/-- Pooled dial value at exact bitlen 48. -/
def pooled56 : ℚ := (seedA + seedB + seedC) / 3
/-- Lower end of the recorded advantage of `T` over the count baseline. -/
def advLow : ℚ := 98 / 1000
/-- Upper end of the recorded advantage of `T` over the count baseline. -/
def advHigh : ℚ := 145 / 1000
/-- The recorded mean relation rate: the unstarved regime. -/
def relationRate : ℚ := 125 / 1000

/-- All three seeds lie strictly inside the validation band `[0.55, 0.85]`. -/
theorem round56_inside_band :
    (55 / 100 : ℚ) < seedA ∧ seedA < 85 / 100 ∧
    (55 / 100 : ℚ) < seedB ∧ seedB < 85 / 100 ∧
    (55 / 100 : ℚ) < seedC ∧ seedC < 85 / 100 := by
  refine ⟨by norm_num [seedA], by norm_num [seedA], by norm_num [seedB], by norm_num [seedB],
    by norm_num [seedC], by norm_num [seedC]⟩

/-- The three seeds agree to within `0.001`: an extremely tight cell. -/
theorem round56_seed_spread :
    |seedA - seedB| ≤ 1 / 1000 ∧ |seedA - seedC| ≤ 1 / 1000 ∧ |seedB - seedC| ≤ 1 / 1000 := by
  refine ⟨?_, ?_, ?_⟩ <;> rw [abs_le] <;>
    constructor <;> norm_num [seedA, seedB, seedC]

/-- Every seed stays below the *refining*-response ceiling of the trailing-zero statistic at
exact bitlen 48 (`windowProfile 47`), so the classical tie ceiling does not exclude them. -/
theorem round56_below_refining_ceiling :
    seedA ^ 2 < spearmanSq (windowProfile 47) ∧
    seedB ^ 2 < spearmanSq (windowProfile 47) ∧
    seedC ^ 2 < spearmanSq (windowProfile 47) := by
  have h : (6 : ℚ) / 7 < spearmanSq (windowProfile 47) := by
    rw [windowProfile_eq_dyadicBlocks]
    exact dyadic_ceiling_gt 47 (by norm_num)
  refine ⟨lt_of_le_of_lt ?_ h, lt_of_le_of_lt ?_ h, lt_of_le_of_lt ?_ h⟩ <;>
    norm_num [seedA, seedB, seedC]

/-! ## 6. The payload: a `12.5 %` relation rate cannot be binary -/

/-- The coarse ceiling at a dyadic rate `2^{-t}` with `t ≥ 3` is below `0.39`, hence far
below the square of every recorded seed. -/
theorem coarse_ceiling_small (b t : ℕ) (hb : 4 ≤ b) (ht : 3 ≤ t) :
    (7 / 2) * (1 / (2 : ℚ) ^ t) * (1 - 1 / (2 : ℚ) ^ t)
        * (((2 : ℚ) ^ b) ^ 3 / (((2 : ℚ) ^ b) ^ 3 - 1)) < 39 / 100 := by
  have hp8 : (1 : ℚ) / (2 : ℚ) ^ t ≤ 1 / 8 := by
    have h8 : (8 : ℚ) ≤ (2 : ℚ) ^ t := by
      calc (8 : ℚ) = 2 ^ 3 := by norm_num
        _ ≤ 2 ^ t := two_pow_ge t 3 ht
    exact one_div_le_one_div_of_le (by norm_num) h8
  have hppos : (0 : ℚ) < 1 / (2 : ℚ) ^ t := by positivity
  have hx3 : (4096 : ℚ) ≤ ((2 : ℚ) ^ b) ^ 3 := by
    have := cube_two_pow_ge b 4 hb
    norm_num at this
    linarith
  have hratio : ((2 : ℚ) ^ b) ^ 3 / (((2 : ℚ) ^ b) ^ 3 - 1) ≤ 4096 / 4095 := by
    rw [div_le_div_iff₀ (by linarith) (by norm_num)]
    linarith
  have hpar : (1 / (2 : ℚ) ^ t) * (1 - 1 / (2 : ℚ) ^ t) ≤ 7 / 64 := by nlinarith
  have hrpos : (0 : ℚ) < ((2 : ℚ) ^ b) ^ 3 / (((2 : ℚ) ^ b) ^ 3 - 1) := by
    apply div_pos <;> linarith
  nlinarith

/-- **The payload.**  At exact bitlen 48 (profile `dyadicBlocks 47`, by the one-bit shift law
of `Novelty.ZeroFitDialExactBitlen48`) *no* binary response whose rate is the recorded
`12.5 %` can produce the recorded dial: its squared Spearman coefficient is at most
`≈ 0.383`, while every seed squares to `≈ 0.517`.  The measured relation rate must
therefore be a genuinely graded response, not a single-trial indicator. -/
theorem relation_response_not_binary {s₁ s₂ : List ℕ}
    (h₁ : List.Forall₂ (· ≤ ·) s₁ ((dyadicBlocks 47).take 3))
    (h₂ : List.Forall₂ (· ≤ ·) s₂ ((dyadicBlocks 47).drop 3))
    (hcount : (s₁.sum : ℚ) + (s₂.sum : ℚ) = (((dyadicBlocks 47).drop 3).sum : ℚ))
    (hcov : 0 ≤ covBin ((dyadicBlocks 47).take 3 ++ (dyadicBlocks 47).drop 3) (s₁ ++ s₂)) :
    spearmanSqBin ((dyadicBlocks 47).take 3 ++ (dyadicBlocks 47).drop 3) (s₁ ++ s₂) < seedA ^ 2 ∧
    spearmanSqBin ((dyadicBlocks 47).take 3 ++ (dyadicBlocks 47).drop 3) (s₁ ++ s₂) < seedB ^ 2 ∧
    spearmanSqBin ((dyadicBlocks 47).take 3 ++ (dyadicBlocks 47).drop 3) (s₁ ++ s₂) < seedC ^ 2 := by
  have hcat : (dyadicBlocks 47).take 3 ++ (dyadicBlocks 47).drop 3 = dyadicBlocks 47 :=
    List.take_append_drop 3 (dyadicBlocks 47)
  have htake : ((((dyadicBlocks 47).take 3).sum : ℕ) : ℚ) = (2 : ℚ) ^ 47 - (2 : ℚ) ^ 44 := by
    have hnat := dyadic_take_sum 47 3 (by norm_num)
    have hq : ((((dyadicBlocks 47).take 3).sum : ℕ) : ℚ) + (2 : ℚ) ^ (47 - 3) = (2 : ℚ) ^ 47 := by
      exact_mod_cast congrArg (fun k : ℕ => (k : ℚ)) hnat
    have h44 : ((2 : ℚ) ^ (47 - 3)) = (2 : ℚ) ^ 44 := by norm_num
    rw [h44] at hq
    linarith
  have hdrop : ((((dyadicBlocks 47).drop 3).sum : ℕ) : ℚ) = (2 : ℚ) ^ 44 := by
    rw [dyadic_drop_sum 47 3 (by norm_num)]; norm_num
  have hssRpos : 0 < ssR (gmean (dyadicBlocks 47)) (dyadicBlocks 47) 0 := by
    rw [ssR_dyadic 47 (by norm_num)]
    have h8 : (8 : ℚ) ≤ ((2 : ℚ) ^ 47) ^ 3 := by
      have := cube_two_pow_ge 47 1 (by norm_num)
      simpa using this
    linarith
  have hle := spearmanSqBin_le_varBin_div_ssR
    (L₁ := (dyadicBlocks 47).take 3) (L₂ := (dyadicBlocks 47).drop 3)
    h₁ h₂ hcount
    (by rw [htake]; norm_num) (by rw [hdrop]; positivity) (by rw [hcat]; exact hssRpos) hcov
  rw [hcat] at hle
  have hceil := dyadic_binary_ceiling 47 3 (by norm_num) (by norm_num)
  rw [hceil] at hle
  have hsmall := coarse_ceiling_small 47 3 (by norm_num) (by norm_num)
  rw [hcat]
  refine ⟨lt_of_le_of_lt hle (lt_trans hsmall ?_), lt_of_le_of_lt hle (lt_trans hsmall ?_),
    lt_of_le_of_lt hle (lt_trans hsmall ?_)⟩ <;> norm_num [seedA, seedB, seedC]

/-- The coarse ceiling at exact bitlen 48 and relation rate `12.5 %` in closed form:
`ρ² = (49/128)·(1 + 1/(2¹⁴¹-1))`, i.e. `ρ ≤ 7/(8√2) ≈ 0.61872`. -/
theorem exact_bitlen48_rate_eighth_ceiling :
    (7 / 2) * (1 / (2 : ℚ) ^ 3) * (1 - 1 / (2 : ℚ) ^ 3)
        * (((2 : ℚ) ^ 47) ^ 3 / (((2 : ℚ) ^ 47) ^ 3 - 1))
      = (49 / 128) * (1 + 1 / ((2 : ℚ) ^ 141 - 1)) := by
  norm_num

/-- **A binary explanation would need twice the recorded rate.**  For every dyadic rate
`2^{-t} ≤ 1/8` the coarse ceiling stays below the measured dial, whereas at rate `1/4` the
parabola `(7/2)p(1-p)` gives `0.65 > 0.517`.  So a two-valued response reproducing the dial
needs a relation rate of at least `25 %`, double the recorded `12.5 %`. -/
theorem binary_model_needs_double_rate (t : ℕ) (ht : 3 ≤ t) :
    (7 / 2) * (1 / (2 : ℚ) ^ t) * (1 - 1 / (2 : ℚ) ^ t)
        * (((2 : ℚ) ^ 47) ^ 3 / (((2 : ℚ) ^ 47) ^ 3 - 1)) < seedA ^ 2 ∧
    seedA ^ 2 < (7 / 2) * (1 / (2 : ℚ) ^ 2) * (1 - 1 / (2 : ℚ) ^ 2)
        * (((2 : ℚ) ^ 47) ^ 3 / (((2 : ℚ) ^ 47) ^ 3 - 1)) := by
  constructor
  · have h := coarse_ceiling_small 47 t (by norm_num) ht
    have hs : (39 : ℚ) / 100 < seedA ^ 2 := by norm_num [seedA]
    linarith
  · have hx3 : (0 : ℚ) < ((2 : ℚ) ^ 47) ^ 3 - 1 := by norm_num
    have hratio : (1 : ℚ) < ((2 : ℚ) ^ 47) ^ 3 / (((2 : ℚ) ^ 47) ^ 3 - 1) := by
      rw [lt_div_iff₀ hx3]; linarith
    have hval : (7 / 2 : ℚ) * (1 / (2 : ℚ) ^ 2) * (1 - 1 / (2 : ℚ) ^ 2) = 21 / 32 := by norm_num
    rw [hval]
    have hs : seedA ^ 2 < 21 / 32 := by norm_num [seedA]
    nlinarith

/-! ## 7. Coarse responses break the `6/7` ceiling, and reverse the count inversion -/

/-- **The `6/7` tie ceiling is not universal.**  A balanced (rate `1/2`) binary response can
reach `ρ² = (7/8)·n³/(n³-1) > 6/7·(1 + 1/(n(n+1)))` for every bitlen `b ≥ 3`: coarsening the
response *raises* the attainable dial, because it shrinks the response's own variance faster
than it shrinks the covariance. -/
theorem coarse_beats_refining_at_half (b : ℕ) (hb : 3 ≤ b) :
    spearmanSq (dyadicBlocks b)
      < (7 / 2) * (1 / (2 : ℚ) ^ 1) * (1 - 1 / (2 : ℚ) ^ 1)
          * (((2 : ℚ) ^ b) ^ 3 / (((2 : ℚ) ^ b) ^ 3 - 1)) := by
  have hx : (8 : ℚ) ≤ (2 : ℚ) ^ b := by
    calc (8 : ℚ) = 2 ^ 3 := by norm_num
      _ ≤ 2 ^ b := two_pow_ge b 3 hb
  have hx3 : (512 : ℚ) ≤ ((2 : ℚ) ^ b) ^ 3 := by
    have := cube_two_pow_ge b 3 hb
    norm_num at this
    linarith
  rw [dyadic_spearmanSq b (by omega)]
  have hprod : (0 : ℚ) < (2 : ℚ) ^ b * ((2 : ℚ) ^ b + 1) := by positivity
  have hinv : 1 / ((2 : ℚ) ^ b * ((2 : ℚ) ^ b + 1)) ≤ 1 / 72 := by
    apply one_div_le_one_div_of_le (by norm_num)
    nlinarith
  have hratio : (1 : ℚ) ≤ ((2 : ℚ) ^ b) ^ 3 / (((2 : ℚ) ^ b) ^ 3 - 1) := by
    rw [le_div_iff₀ (by linarith)]; linarith
  have hval : (7 / 2 : ℚ) * (1 / (2 : ℚ) ^ 1) * (1 - 1 / (2 : ℚ) ^ 1) = 7 / 8 := by norm_num
  rw [hval]
  nlinarith

/-- `ssR` in terms of the tie ceiling. -/
lemma ssR_eq_spearmanSq_mul (L : List ℕ) (h : 2 ≤ L.sum) :
    ssR (gmean L) L 0 = spearmanSq L * (((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) / 12) := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hssS : ssS (gmean L) L 0 = ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) / 12 := ssS_total L
  have hcube := cube_sub_self_pos hn
  have hpos : 0 < ssS (gmean L) L 0 := by rw [hssS]; linarith
  rw [← hssS, spearmanSq, div_mul_cancel₀ _ (ne_of_gt hpos)]

/-- **The tie-headroom inversion reverses for a rate response.**  At exact bitlen 48 the
popcount baseline has strictly more *refining* headroom than the trailing-zero statistic
(`Novelty.ZeroFitDialExactBitlen48.exact_bitlen48_ceiling_inversion`).  For a *coarse* rate
response the ordering flips: at every aligned split the count baseline's ceiling is strictly
below `T`'s.  The recorded advantage of `T` over count therefore points the way the coarse
theory predicts. -/
theorem binary_ceiling_inversion_reversal (K : ℚ) (hK : 0 < K) (hK' : K < (2 : ℚ) ^ 47) :
    (2 : ℚ) ^ 47 * K * ((2 : ℚ) ^ 47 - K) / (4 * ssR (gmean (binomBlocks 47)) (binomBlocks 47) 0)
      < (2 : ℚ) ^ 47 * K * ((2 : ℚ) ^ 47 - K)
          / (4 * ssR (gmean (dyadicBlocks 47)) (dyadicBlocks 47) 0) := by
  have hsumD : (dyadicBlocks 47).sum = 2 ^ 47 := dyadicBlocks_sum 47
  have hsumB : (binomBlocks 47).sum = 2 ^ 47 := binomBlocks_sum 47
  have h2D : 2 ≤ (dyadicBlocks 47).sum := by rw [hsumD]; norm_num
  have h2B : 2 ≤ (binomBlocks 47).sum := by rw [hsumB]; norm_num
  have hcastD : (((dyadicBlocks 47).sum : ℕ) : ℚ) = (2 : ℚ) ^ 47 := by rw [hsumD]; push_cast; ring
  have hcastB : (((binomBlocks 47).sum : ℕ) : ℚ) = (2 : ℚ) ^ 47 := by rw [hsumB]; push_cast; ring
  have hcube : (0 : ℚ) < (((2 : ℚ) ^ 47) ^ 3 - (2 : ℚ) ^ 47) / 12 := by norm_num
  have hD := ssR_eq_spearmanSq_mul (dyadicBlocks 47) h2D
  have hB := ssR_eq_spearmanSq_mul (binomBlocks 47) h2B
  rw [hcastD] at hD
  rw [hcastB] at hB
  have hinv : spearmanSq (dyadicBlocks 47) < spearmanSq (binomBlocks 47) := by
    have h := exact_bitlen48_ceiling_inversion
    rwa [windowProfile_eq_dyadicBlocks, weightWindowProfile_eq_binomBlocks] at h
  have hDpos : 0 < spearmanSq (dyadicBlocks 47) := by
    have h6 : (6 : ℚ) / 7 < spearmanSq (dyadicBlocks 47) := dyadic_ceiling_gt 47 (by norm_num)
    linarith
  have hssRD : 0 < ssR (gmean (dyadicBlocks 47)) (dyadicBlocks 47) 0 := by
    rw [hD]; positivity
  have hlt : ssR (gmean (dyadicBlocks 47)) (dyadicBlocks 47) 0
      < ssR (gmean (binomBlocks 47)) (binomBlocks 47) 0 := by
    rw [hD, hB]
    exact mul_lt_mul_of_pos_right hinv hcube
  have hnum : 0 < (2 : ℚ) ^ 47 * K * ((2 : ℚ) ^ 47 - K) := by
    have hpos : (0 : ℚ) < (2 : ℚ) ^ 47 - K := by linarith
    positivity
  apply div_lt_div_of_pos_left hnum (by linarith)
  linarith

/-- The recorded advantage of `T` over the count baseline is strictly positive throughout its
reported range, and the implied count value stays inside the validation band. -/
theorem round56_advantage_positive :
    0 < advLow ∧ advLow < advHigh ∧ (55 / 100 : ℚ) < pooled56 - advHigh := by
  refine ⟨by norm_num [advLow], by norm_num [advLow, advHigh], ?_⟩
  norm_num [pooled56, seedA, seedB, seedC, advHigh]

/-- The recorded relation rate is the dyadic rate `2^{-3}`: the split used above is exactly
the recorded regime. -/
theorem round56_rate_is_dyadic : relationRate = 1 / (2 : ℚ) ^ 3 := by
  norm_num [relationRate]

end Catalog.Pythagorean.ZeroFitDialRelationRate48