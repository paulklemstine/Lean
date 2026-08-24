import Mathlib
import Novelty.ZeroFitDialU64
import Pythagorean.ZeroFitDialRelationRate48
import Pythagorean.ZeroFitDialChannelDilution88

/-!
# The product law: tie attenuation times channel dilution, and which erosion law survives

## Research context (FACT round-68 #1, exp 536, `TDIAL-U88`, cycle 2)

Cycle 1 (`Pythagorean.ZeroFitDialChannelDilution88`) established two things about the
uniform ladder that ends in the bitlen-88 band miss: the erosion follows an *inverse-bitlen*
law `ρ²·b ≈ 26.47` which retrodicts the first miss at the 88-rung, and the *literal*
fixed-weight channel model is falsified because it decays too slowly.  Two questions were
left open, and this file settles both.

**(Q1) How do the two known attenuation mechanisms combine?**  The catalog has an exact tie
ceiling (`Novelty.ZeroFitDialU64`) and cycle 1 has an exact dilution law.  Do they interact,
or do they simply multiply?  Answer: they multiply, exactly, with no interaction term.

**(Q2) Is the inverse-bitlen law on the `ρ²` scale, or on the odds scale?**  Both fit the
trend; they disagree about *where the band is first missed*, and the ladder discriminates.

## Main results

### 1. The product law
* `pearsonSqC`, `pearsonSqC_eq_pearsonSq` — Pearson's coefficient in explicitly centred form,
  and its agreement with the determinant form of cycle 1 at the sample means.
* `midrankPairs`, `midrank_ssR`, `midrank_ssS`, `midrank_sp`, `midrank_massR_fst/snd` — the
  midrank/rank sample of a tie profile, whose centred moments are *exactly* the catalog's
  `ssR`, `ssS`, `sp` and `massR`.  This is the bridge between the catalog's recursive
  tie calculus and an honest finite-sample correlation.
* `productSample` — the tie profile crossed with an independent `m`-channel noise cube: the
  response is `a·(refining rank) + c·(channel sum)`.
* `product_law` — **the payload**: exactly
  `ρ² = a²·ssR / (a²·ssS + c²·n·m/4)`,
  and `product_law_factorised`: `ρ² = ρ²_tie(L) · a²ssS/(a²ssS + c²nm/4)`.
  **Tie attenuation and channel dilution compose multiplicatively**, with the noise entering
  only through the single scalar `c²nm/4`; every cross term cancels because the midrank mass
  of a profile about its grand mean is zero.
* `product_law_dyadic`, `dyadic_dilution_lt` — the dyadic evaluation at noise scale `c = n`,
  and the clean bound `dilution < a²/(a² + 3m)`.

### 2. Adversarial review: uniform falsification of linear pool growth
* `linear_pool_growth_excluded` — for **every** channel weight `a ≠ 0` and **every** pool
  growth rate `κ > 0`, the law `a²/(a² + κ·(b-1))` decays too slowly between bitlen 44 and 88
  to match the recorded ladder.  Cycle 1 proved this for `κ = 1`; it is in fact true for the
  entire two-parameter family, so no fixed-weight, linearly-growing channel pool can produce
  the observed erosion.

### 3. Model discrimination: the `ρ²` scale beats the odds scale
* `odds`, `oddsConst`, `odds_constant_window` — the competing hypothesis `ρ²/(1-ρ²) = K/b²`
  also fits the ladder: all nine non-outlier rungs have `K ∈ [2700, 3450]`.
* `pooledK_bounds`, `odds_law_predicts_miss_at_84`, `odds_law_falsified_by_the_84_rung` —
  but the odds law puts the first band miss at the **84**-rung, and the 84-rung held at
  `0.56 ≥ 0.55`.  The odds-scale inverse-square law is therefore rejected, while the
  `ρ²`-scale inverse law of cycle 1 (crossing at `87.5`) survives the same test.
* `effective_pool_superlinear` — model-independently, the fitted noise pool grows by a factor
  in `(3.8, 4)` while the bitlen only doubles: the pool grows *superlinearly*, close to `b²`.
  This is the precise sense in which the ladder is "super-dilute", and it is what
  `linear_pool_growth_excluded` forces.
-/

open Finset
open Catalog.Novelty.ZeroFitDialU64
open Catalog.Pythagorean.ZeroFitDialRelationRate48
open Catalog.Pythagorean.ZeroFitDialChannelDilution88

namespace Catalog.Pythagorean.ZeroFitDialProductLaw88

/-! ## 1. Centred Pearson coefficient and the bridge to the determinant form -/

/-- Pearson's squared coefficient in explicitly centred form. -/
def pearsonSqC (D : List (ℚ × ℚ)) (mx my : ℚ) : ℚ :=
  (lsum D fun p => (p.1 - mx) * (p.2 - my)) ^ 2 /
    ((lsum D fun p => (p.1 - mx) ^ 2) * (lsum D fun p => (p.2 - my) ^ 2))

/-- Sample mean of the predictor. -/
def meanX (D : List (ℚ × ℚ)) : ℚ := lsum D Prod.fst / sampleN D

/-- Sample mean of the response. -/
def meanY (D : List (ℚ × ℚ)) : ℚ := lsum D Prod.snd / sampleN D

lemma lsum_sub_const_fst (D : List (ℚ × ℚ)) (mx : ℚ) :
    lsum D (fun p => p.1 - mx) = lsum D Prod.fst - sampleN D * mx := by
  have h : (fun p : ℚ × ℚ => p.1 - mx) = fun p : ℚ × ℚ => p.1 + (-mx) := by funext p; ring
  rw [h, lsum_add, lsum_const, sampleN]
  ring

lemma lsum_sub_const_snd (D : List (ℚ × ℚ)) (my : ℚ) :
    lsum D (fun p => p.2 - my) = lsum D Prod.snd - sampleN D * my := by
  have h : (fun p : ℚ × ℚ => p.2 - my) = fun p : ℚ × ℚ => p.2 + (-my) := by funext p; ring
  rw [h, lsum_add, lsum_const, sampleN]
  ring

/-- If the centred predictor sums to zero, the centring constant *is* the sample mean. -/
lemma meanX_of_centred (D : List (ℚ × ℚ)) (mx : ℚ) (hn : sampleN D ≠ 0)
    (h : lsum D (fun p => p.1 - mx) = 0) : meanX D = mx := by
  rw [lsum_sub_const_fst] at h
  rw [meanX, div_eq_iff hn]
  linarith

/-- If the centred response sums to zero, the centring constant *is* the sample mean. -/
lemma meanY_of_centred (D : List (ℚ × ℚ)) (my : ℚ) (hn : sampleN D ≠ 0)
    (h : lsum D (fun p => p.2 - my) = 0) : meanY D = my := by
  rw [lsum_sub_const_snd] at h
  rw [meanY, div_eq_iff hn]
  linarith

lemma centred_cross_eq (D : List (ℚ × ℚ)) (hn : sampleN D ≠ 0) :
    lsum D (fun p => (p.1 - meanX D) * (p.2 - meanY D)) = covXY D / sampleN D := by
  have hexp : (fun p : ℚ × ℚ => (p.1 - meanX D) * (p.2 - meanY D))
      = fun p : ℚ × ℚ => p.1 * p.2 + ((-(meanY D)) * p.1
          + ((-(meanX D)) * p.2 + meanX D * meanY D)) := by
    funext p; ring
  rw [hexp, lsum_add, lsum_add, lsum_add, lsum_mul_left, lsum_mul_left, lsum_const, covXY,
    meanX, meanY]
  have hnl : ((D.length : ℚ)) = sampleN D := rfl
  rw [hnl]
  field_simp
  ring

lemma centred_x_eq (D : List (ℚ × ℚ)) (hn : sampleN D ≠ 0) :
    lsum D (fun p => (p.1 - meanX D) ^ 2) = varX D / sampleN D := by
  have hexp : (fun p : ℚ × ℚ => (p.1 - meanX D) ^ 2)
      = fun p : ℚ × ℚ => p.1 ^ 2 + ((-(2 * meanX D)) * p.1 + meanX D ^ 2) := by
    funext p; ring
  rw [hexp, lsum_add, lsum_add, lsum_mul_left, lsum_const, varX, meanX]
  have hnl : ((D.length : ℚ)) = sampleN D := rfl
  rw [hnl]
  field_simp
  ring

lemma centred_y_eq (D : List (ℚ × ℚ)) (hn : sampleN D ≠ 0) :
    lsum D (fun p => (p.2 - meanY D) ^ 2) = varY D / sampleN D := by
  have hexp : (fun p : ℚ × ℚ => (p.2 - meanY D) ^ 2)
      = fun p : ℚ × ℚ => p.2 ^ 2 + ((-(2 * meanY D)) * p.2 + meanY D ^ 2) := by
    funext p; ring
  rw [hexp, lsum_add, lsum_add, lsum_mul_left, lsum_const, varY, meanY]
  have hnl : ((D.length : ℚ)) = sampleN D := rfl
  rw [hnl]
  field_simp
  ring

/-- **The two forms of Pearson's coefficient agree.**  Centring at the sample means gives the
determinant form used in cycle 1. -/
theorem pearsonSqC_eq_pearsonSq (D : List (ℚ × ℚ)) (hn : sampleN D ≠ 0) :
    pearsonSqC D (meanX D) (meanY D) = pearsonSq D := by
  rw [pearsonSqC, centred_cross_eq D hn, centred_x_eq D hn, centred_y_eq D hn, pearsonSq]
  rcases eq_or_ne (varX D * varY D) 0 with h0 | h0
  · simp [div_mul_div_comm, h0]
  · have hx : varX D ≠ 0 := left_ne_zero_of_mul h0
    have hy : varY D ≠ 0 := right_ne_zero_of_mul h0
    field_simp

/-! ## 2. The midrank sample of a tie profile -/

/-- The paired sample `(midrank of T, refining rank)` of a tie profile, offset by `c`. -/
def midrankPairs : List ℕ → ℚ → List (ℚ × ℚ)
  | [], _ => []
  | m :: L, c =>
      (List.range m).map (fun t : ℕ => (c + ((m : ℚ) + 1) / 2, c + (t : ℚ) + 1))
        ++ midrankPairs L (c + m)

lemma list_range_sum (m : ℕ) (f : ℕ → ℚ) :
    ((List.range m).map f).sum = ∑ t ∈ Finset.range m, f t := by
  induction m with
  | zero => simp
  | succ m ih => rw [List.range_succ, List.map_append, List.sum_append, ih, Finset.sum_range_succ]
                 simp

lemma lsum_map_pairs (D : List (ℚ × ℚ)) (g : ℚ × ℚ → ℚ × ℚ) (f : ℚ × ℚ → ℚ) :
    lsum (D.map g) f = lsum D (fun p => f (g p)) := by
  rw [lsum, List.map_map]
  rfl

lemma lsum_range_map (m : ℕ) (g : ℕ → ℚ × ℚ) (f : ℚ × ℚ → ℚ) :
    lsum ((List.range m).map g) f = ∑ t ∈ Finset.range m, f (g t) := by
  rw [lsum, List.map_map, list_range_sum]
  rfl

lemma midrankPairs_length (L : List ℕ) (c : ℚ) : (midrankPairs L c).length = L.sum := by
  induction L generalizing c with
  | nil => simp [midrankPairs]
  | cons m L ih => simp [midrankPairs, ih, List.sum_cons]

/-- The centred sum of squares of the midranks is the catalog's `ssR`. -/
lemma midrank_ssR (mu : ℚ) (L : List ℕ) (c : ℚ) :
    lsum (midrankPairs L c) (fun p => (p.1 - mu) ^ 2) = ssR mu L c := by
  induction L generalizing c with
  | nil => simp [midrankPairs, ssR]
  | cons m L ih =>
      rw [midrankPairs, lsum_append, lsum_range_map, ih, ssR]
      congr 1
      simp

/-- The centred sum of squares of the refining ranks is the catalog's `ssS`. -/
lemma midrank_ssS (mu : ℚ) (L : List ℕ) (c : ℚ) :
    lsum (midrankPairs L c) (fun p => (p.2 - mu) ^ 2) = ssS mu L c := by
  induction L generalizing c with
  | nil => simp [midrankPairs, ssS]
  | cons m L ih =>
      rw [midrankPairs, lsum_append, lsum_range_map, ih, ssS]

/-- The centred cross moment is the catalog's `sp`. -/
lemma midrank_sp (mu : ℚ) (L : List ℕ) (c : ℚ) :
    lsum (midrankPairs L c) (fun p => (p.1 - mu) * (p.2 - mu)) = sp mu L c := by
  induction L generalizing c with
  | nil => simp [midrankPairs, sp]
  | cons m L ih =>
      rw [midrankPairs, lsum_append, lsum_range_map, ih, sp]

/-- The centred midrank mass is the catalog's `massR`. -/
lemma midrank_massR_fst (mu : ℚ) (L : List ℕ) (c : ℚ) :
    lsum (midrankPairs L c) (fun p => p.1 - mu) = massR mu L c := by
  induction L generalizing c with
  | nil => simp [midrankPairs, massR]
  | cons m L ih =>
      rw [midrankPairs, lsum_append, lsum_range_map, ih, massR]
      congr 1
      simp
      ring

/-- The centred raw-rank mass equals the centred midrank mass. -/
lemma midrank_massR_snd (mu : ℚ) (L : List ℕ) (c : ℚ) :
    lsum (midrankPairs L c) (fun p => p.2 - mu) = massR mu L c := by
  induction L generalizing c with
  | nil => simp [midrankPairs, massR]
  | cons m L ih =>
      rw [midrankPairs, lsum_append, lsum_range_map, ih, massR]
      congr 1
      have h : ∀ t ∈ Finset.range m, (c + (t : ℚ) + 1 - mu) = ((t : ℚ) + 1) + (c - mu) := by
        intros; ring
      rw [Finset.sum_congr rfl h, Finset.sum_add_distrib, sum_rank, Finset.sum_const,
        card_range, nsmul_eq_mul]
      ring

/-- About the grand mean, the midrank mass vanishes. -/
lemma midrank_mass_zero (L : List ℕ) :
    lsum (midrankPairs L 0) (fun p => p.1 - gmean L) = 0 := by
  rw [midrank_massR_fst, massR_closed, gmean]
  ring

lemma midrank_mass_zero' (L : List ℕ) :
    lsum (midrankPairs L 0) (fun p => p.2 - gmean L) = 0 := by
  rw [midrank_massR_snd, massR_closed, gmean]
  ring

/-! ## 3. The noise cube: centred variance of the channel sum -/

/-- `4·Σ_w (w - m/2)² = m·2^m`: the `m`-channel noise has variance `m/4`. -/
lemma wvar_eq (m : ℕ) :
    4 * ((weights m).map (fun w => (w - (m : ℚ) / 2) ^ 2)).sum = (m : ℚ) * 2 ^ m := by
  have hexp : ((weights m).map (fun w => (w - (m : ℚ) / 2) ^ 2)).sum
      = ((weights m).map (fun w => w ^ 2)).sum - (m : ℚ) * (weights m).sum
        + ((weights m).length : ℚ) * ((m : ℚ) / 2) ^ 2 := by
    induction (weights m) with
    | nil => simp
    | cons w L ih =>
        rw [List.map_cons, List.sum_cons, ih, List.map_cons, List.sum_cons, List.sum_cons,
          List.length_cons]
        push_cast
        ring
  rw [hexp, ← wsq, ← wsum, weights_length]
  have hs := wsum_eq m
  have hq := wsq_eq m
  push_cast
  linear_combination hq - 2 * (m : ℚ) * hs

/-! ## 4. The product sample and the product law -/

/-- The tie profile crossed with an independent `m`-channel noise cube: the predictor is the
midrank of `T`, the response is `a·(refining rank) + c·(channel sum)`. -/
def productSample (L : List ℕ) (a c : ℚ) (m : ℕ) : List (ℚ × ℚ) :=
  (weights m).flatMap fun w => (midrankPairs L 0).map (fun p => (p.1, a * p.2 + c * w))

lemma lsum_flatMap (W : List ℚ) (F : ℚ → List (ℚ × ℚ)) (f : ℚ × ℚ → ℚ) :
    lsum (W.flatMap F) f = (W.map (fun w => lsum (F w) f)).sum := by
  induction W with
  | nil => simp [lsum]
  | cons w W ih => rw [List.flatMap_cons, lsum_append, ih, List.map_cons, List.sum_cons]

lemma productSample_length (L : List ℕ) (a c : ℚ) (m : ℕ) :
    sampleN (productSample L a c m) = 2 ^ m * (L.sum : ℚ) := by
  have h : lsum (productSample L a c m) (fun _ => 1) = 2 ^ m * (L.sum : ℚ) := by
    rw [productSample, lsum_flatMap]
    have hinner : ∀ w : ℚ, lsum ((midrankPairs L 0).map (fun p => (p.1, a * p.2 + c * w)))
        (fun _ => (1 : ℚ)) = (L.sum : ℚ) := by
      intro w
      rw [lsum_map_pairs, lsum_const, midrankPairs_length]
      ring
    rw [List.map_congr_left (fun w _ => hinner w), sum_map_const, weights_length]
    push_cast
    ring
  rw [lsum_const] at h
  rw [sampleN]
  linarith

/-- Centred predictor moment of the product sample. -/
lemma product_varX (L : List ℕ) (a c : ℚ) (m : ℕ) :
    lsum (productSample L a c m) (fun p => (p.1 - gmean L) ^ 2)
      = 2 ^ m * ssR (gmean L) L 0 := by
  rw [productSample, lsum_flatMap]
  have hinner : ∀ w : ℚ, lsum ((midrankPairs L 0).map (fun p => (p.1, a * p.2 + c * w)))
      (fun p => (p.1 - gmean L) ^ 2) = ssR (gmean L) L 0 := by
    intro w
    rw [lsum_map_pairs, midrank_ssR]
  rw [List.map_congr_left (fun w _ => hinner w), sum_map_const, weights_length]
  push_cast
  ring

/-- Centred cross moment of the product sample: the noise contributes nothing. -/
lemma product_cov (L : List ℕ) (a c : ℚ) (m : ℕ) :
    lsum (productSample L a c m)
        (fun p => (p.1 - gmean L) * (p.2 - (a * gmean L + c * (m : ℚ) / 2)))
      = 2 ^ m * (a * ssR (gmean L) L 0) := by
  rw [productSample, lsum_flatMap]
  have hinner : ∀ w : ℚ, lsum ((midrankPairs L 0).map (fun p => (p.1, a * p.2 + c * w)))
      (fun p => (p.1 - gmean L) * (p.2 - (a * gmean L + c * (m : ℚ) / 2)))
      = a * ssR (gmean L) L 0 := by
    intro w
    rw [lsum_map_pairs]
    have hexp : (fun p : ℚ × ℚ => (p.1 - gmean L)
          * ((a * p.2 + c * w) - (a * gmean L + c * (m : ℚ) / 2)))
        = fun p : ℚ × ℚ => a * ((p.1 - gmean L) * (p.2 - gmean L))
            + (c * (w - (m : ℚ) / 2)) * (p.1 - gmean L) := by
      funext p; ring
    rw [hexp, lsum_add, lsum_mul_left, lsum_mul_left, midrank_sp, midrank_mass_zero,
      sp_eq_ssR]
    ring
  rw [List.map_congr_left (fun w _ => hinner w), sum_map_const, weights_length]
  push_cast
  ring

/-- Centred response moment of the product sample: rank signal plus independent noise. -/
lemma product_varY (L : List ℕ) (a c : ℚ) (m : ℕ) :
    lsum (productSample L a c m) (fun p => (p.2 - (a * gmean L + c * (m : ℚ) / 2)) ^ 2)
      = 2 ^ m * (a ^ 2 * ssS (gmean L) L 0) + c ^ 2 * (L.sum : ℚ) * ((m : ℚ) * 2 ^ m / 4) := by
  rw [productSample, lsum_flatMap]
  have hinner : ∀ w : ℚ, lsum ((midrankPairs L 0).map (fun p => (p.1, a * p.2 + c * w)))
      (fun p => (p.2 - (a * gmean L + c * (m : ℚ) / 2)) ^ 2)
      = a ^ 2 * ssS (gmean L) L 0 + c ^ 2 * (w - (m : ℚ) / 2) ^ 2 * (L.sum : ℚ) := by
    intro w
    rw [lsum_map_pairs]
    have hexp : (fun p : ℚ × ℚ => ((a * p.2 + c * w) - (a * gmean L + c * (m : ℚ) / 2)) ^ 2)
        = fun p : ℚ × ℚ => a ^ 2 * ((p.2 - gmean L) ^ 2)
            + ((2 * a * (c * (w - (m : ℚ) / 2))) * (p.2 - gmean L)
              + c ^ 2 * (w - (m : ℚ) / 2) ^ 2) := by
      funext p; ring
    rw [hexp, lsum_add, lsum_add, lsum_mul_left, lsum_mul_left, lsum_const, midrank_ssS,
      midrank_mass_zero', midrankPairs_length]
    ring
  rw [List.map_congr_left (fun w _ => hinner w)]
  have hsplit : ((weights m).map (fun w => a ^ 2 * ssS (gmean L) L 0
        + c ^ 2 * (w - (m : ℚ) / 2) ^ 2 * (L.sum : ℚ))).sum
      = ((weights m).map (fun _ => a ^ 2 * ssS (gmean L) L 0)).sum
        + (c ^ 2 * (L.sum : ℚ)) * ((weights m).map (fun w => (w - (m : ℚ) / 2) ^ 2)).sum := by
    induction (weights m) with
    | nil => simp
    | cons w W ih =>
        rw [List.map_cons, List.sum_cons, ih, List.map_cons, List.sum_cons, List.map_cons,
          List.sum_cons]
        ring
  rw [hsplit, sum_map_const, weights_length]
  have hw := wvar_eq m
  set S : ℚ := ((weights m).map (fun w => (w - (m : ℚ) / 2) ^ 2)).sum with hS
  set n : ℚ := ((L.sum : ℕ) : ℚ) with hnn
  push_cast
  linear_combination (c ^ 2 * n / 4) * hw

/-- The grand means of the product sample are the obvious ones. -/
lemma product_means (L : List ℕ) (a c : ℚ) (m : ℕ) (hL : 0 < L.sum) :
    meanX (productSample L a c m) = gmean L ∧
    meanY (productSample L a c m) = a * gmean L + c * (m : ℚ) / 2 := by
  have hLq : (0 : ℚ) < (L.sum : ℚ) := by exact_mod_cast hL
  have hn : sampleN (productSample L a c m) ≠ 0 := by
    rw [productSample_length]
    positivity
  constructor
  · refine meanX_of_centred _ _ hn ?_
    rw [productSample, lsum_flatMap]
    have hinner : ∀ w : ℚ, lsum ((midrankPairs L 0).map (fun p => (p.1, a * p.2 + c * w)))
        (fun p => p.1 - gmean L) = 0 := by
      intro w
      rw [lsum_map_pairs, midrank_mass_zero]
    rw [List.map_congr_left (fun w _ => hinner w), sum_map_const]
    ring
  · refine meanY_of_centred _ _ hn ?_
    rw [productSample, lsum_flatMap]
    have hinner : ∀ w : ℚ, lsum ((midrankPairs L 0).map (fun p => (p.1, a * p.2 + c * w)))
        (fun p => p.2 - (a * gmean L + c * (m : ℚ) / 2))
        = c * (w - (m : ℚ) / 2) * (L.sum : ℚ) := by
      intro w
      rw [lsum_map_pairs]
      have hexp : (fun p : ℚ × ℚ => (a * p.2 + c * w) - (a * gmean L + c * (m : ℚ) / 2))
          = fun p : ℚ × ℚ => a * (p.2 - gmean L) + c * (w - (m : ℚ) / 2) := by
        funext p; ring
      rw [hexp, lsum_add, lsum_mul_left, lsum_const, midrank_mass_zero', midrankPairs_length]
      ring
    rw [List.map_congr_left (fun w _ => hinner w)]
    have hsum : ((weights m).map (fun w => c * (w - (m : ℚ) / 2) * (L.sum : ℚ))).sum
        = c * (L.sum : ℚ) * ((weights m).sum - ((weights m).length : ℚ) * ((m : ℚ) / 2)) := by
      induction (weights m) with
      | nil => simp
      | cons w W ih =>
          rw [List.map_cons, List.sum_cons, ih, List.sum_cons, List.length_cons]
          push_cast
          ring
    rw [hsum, ← wsum, weights_length]
    have hs := wsum_eq m
    set n : ℚ := ((L.sum : ℕ) : ℚ) with hnn
    push_cast
    linear_combination (c * n / 2) * hs

/-- **The product law.**  For the tie profile `L` crossed with `m` independent noise channels,
with the response `a·(refining rank) + c·(channel sum)`, Pearson's squared coefficient is
exactly `a²·ssR / (a²·ssS + c²·n·m/4)`.  All cross terms between the tie structure and the
noise cancel identically. -/
theorem product_law (L : List ℕ) (a c : ℚ) (m : ℕ) :
    pearsonSqC (productSample L a c m) (gmean L) (a * gmean L + c * (m : ℚ) / 2)
      = a ^ 2 * ssR (gmean L) L 0
        / (a ^ 2 * ssS (gmean L) L 0 + c ^ 2 * (L.sum : ℚ) * (m : ℚ) / 4) := by
  rw [pearsonSqC, product_cov, product_varX, product_varY]
  have hp : (0 : ℚ) < (2 : ℚ) ^ m := by positivity
  rcases eq_or_ne (ssR (gmean L) L 0) 0 with h0 | h0
  · rw [h0]
    simp
  · have hrw : 2 ^ m * (a ^ 2 * ssS (gmean L) L 0) + c ^ 2 * (L.sum : ℚ) * ((m : ℚ) * 2 ^ m / 4)
        = 2 ^ m * (a ^ 2 * ssS (gmean L) L 0 + c ^ 2 * (L.sum : ℚ) * (m : ℚ) / 4) := by ring
    rw [hrw]
    rcases eq_or_ne (a ^ 2 * ssS (gmean L) L 0 + c ^ 2 * (L.sum : ℚ) * (m : ℚ) / 4) 0 with hz | hz
    · rw [hz]
      simp
    · field_simp

/-- **The product law for the sample-mean-centred (i.e. genuine) Pearson coefficient.**
Combining `product_means` with the bridge `pearsonSqC_eq_pearsonSq`, the identity holds for
the correlation itself, with no centring constants supplied by hand. -/
theorem product_law_pearson (L : List ℕ) (a c : ℚ) (m : ℕ) (hL : 0 < L.sum) :
    pearsonSq (productSample L a c m)
      = a ^ 2 * ssR (gmean L) L 0
        / (a ^ 2 * ssS (gmean L) L 0 + c ^ 2 * (L.sum : ℚ) * (m : ℚ) / 4) := by
  have hLq : (0 : ℚ) < (L.sum : ℚ) := by exact_mod_cast hL
  have hn : sampleN (productSample L a c m) ≠ 0 := by
    rw [productSample_length]
    positivity
  obtain ⟨h1, h2⟩ := product_means L a c m hL
  rw [← pearsonSqC_eq_pearsonSq _ hn, h1, h2, product_law]

/-- **Factorised form.**  `ρ² = ρ²_tie(L) · a²ssS/(a²ssS + c²nm/4)`: tie attenuation and
channel dilution compose multiplicatively. -/
theorem product_law_factorised (L : List ℕ) (a c : ℚ) (m : ℕ) (h2 : 2 ≤ L.sum) :
    pearsonSqC (productSample L a c m) (gmean L) (a * gmean L + c * (m : ℚ) / 2)
      = spearmanSq L
        * (a ^ 2 * ssS (gmean L) L 0
            / (a ^ 2 * ssS (gmean L) L 0 + c ^ 2 * (L.sum : ℚ) * (m : ℚ) / 4)) := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h2
  have hSpos : (0 : ℚ) < ssS (gmean L) L 0 := by
    rw [ssS_total]
    have := cube_sub_self_pos hn
    linarith
  have hssR : ssR (gmean L) L 0 = spearmanSq L * ssS (gmean L) L 0 := by
    rw [spearmanSq, div_mul_cancel₀ _ (ne_of_gt hSpos)]
  rw [product_law, hssR]
  rcases eq_or_ne (a ^ 2 * ssS (gmean L) L 0 + c ^ 2 * (L.sum : ℚ) * (m : ℚ) / 4) 0 with hz | hz
  · rw [hz]
    simp
  · field_simp

/-- Rescaling a dilution fraction: `(A/12)/(A/12 + B/4) = A/(A + 3B)`. -/
lemma dilution_form (A B : ℚ) : (A / 12) / (A / 12 + B / 4) = A / (A + 3 * B) := by
  rcases eq_or_ne (A + 3 * B) 0 with h0 | h0
  · have h1 : A / 12 + B / 4 = 0 := by
      have : A / 12 + B / 4 = (A + 3 * B) / 12 := by ring
      rw [this, h0]
      norm_num
    rw [h0, h1, div_zero, div_zero]
  · have h1 : A / 12 + B / 4 ≠ 0 := by
      intro hc
      apply h0
      have : A / 12 + B / 4 = (A + 3 * B) / 12 := by ring
      rw [this] at hc
      field_simp at hc
      linarith
    rw [div_eq_div_iff h1 h0]
    ring

/-- **Dyadic evaluation.**  At bitlen `b`, noise scale `c = n = 2^b` and `m` channels, the
product law reads `ρ² = ρ²_tie(b) · a²(n³ - n)/(a²(n³ - n) + 3n³m)`. -/
theorem product_law_dyadic (b m : ℕ) (a : ℚ) (hb : 1 ≤ b) :
    pearsonSqC (productSample (dyadicBlocks b) a ((2 : ℚ) ^ b) m) (gmean (dyadicBlocks b))
        (a * gmean (dyadicBlocks b) + (2 : ℚ) ^ b * (m : ℚ) / 2)
      = spearmanSq (dyadicBlocks b)
        * (a ^ 2 * (((2 : ℚ) ^ b) ^ 3 - (2 : ℚ) ^ b)
            / (a ^ 2 * (((2 : ℚ) ^ b) ^ 3 - (2 : ℚ) ^ b) + 3 * (((2 : ℚ) ^ b) ^ 3 * (m : ℚ)))) := by
  have hsum : (dyadicBlocks b).sum = 2 ^ b := dyadicBlocks_sum b
  have h2 : 2 ≤ (dyadicBlocks b).sum := by
    rw [hsum]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb
  have hcast : (((dyadicBlocks b).sum : ℕ) : ℚ) = (2 : ℚ) ^ b := by rw [hsum]; push_cast; ring
  have hssS : ssS (gmean (dyadicBlocks b)) (dyadicBlocks b) 0
      = (((2 : ℚ) ^ b) ^ 3 - (2 : ℚ) ^ b) / 12 := by
    rw [ssS_total, hcast]
  rw [product_law_factorised _ _ _ _ h2, hssS, hcast]
  congr 1
  have e1 : a ^ 2 * ((((2 : ℚ) ^ b) ^ 3 - (2 : ℚ) ^ b) / 12)
      = (a ^ 2 * ((((2 : ℚ) ^ b) ^ 3 - (2 : ℚ) ^ b))) / 12 := by ring
  have e2 : ((2 : ℚ) ^ b) ^ 2 * (2 : ℚ) ^ b * (m : ℚ) / 4
      = (((2 : ℚ) ^ b) ^ 3 * (m : ℚ)) / 4 := by ring
  rw [e1, e2, dilution_form]

/-- The dyadic dilution factor is strictly below the asymptotic `a²/(a² + 3m)`. -/
theorem dyadic_dilution_lt (b m : ℕ) (a : ℚ) (hb : 1 ≤ b) (ha : a ≠ 0) (hm : 0 < m) :
    a ^ 2 * (((2 : ℚ) ^ b) ^ 3 - (2 : ℚ) ^ b)
        / (a ^ 2 * (((2 : ℚ) ^ b) ^ 3 - (2 : ℚ) ^ b) + 3 * (((2 : ℚ) ^ b) ^ 3 * (m : ℚ)))
      < a ^ 2 / (a ^ 2 + 3 * (m : ℚ)) := by
  have ha2 : 0 < a ^ 2 := by positivity
  have hmq : (1 : ℚ) ≤ (m : ℚ) := by exact_mod_cast hm
  have hx : (0 : ℚ) < (2 : ℚ) ^ b := by positivity
  have hn : (2 : ℚ) ≤ (2 : ℚ) ^ b := by
    calc (2 : ℚ) = 2 ^ 1 := (pow_one 2).symm
      _ ≤ 2 ^ b := pow_le_pow_right₀ (by norm_num) hb
  have hsq : (4 : ℚ) ≤ ((2 : ℚ) ^ b) ^ 2 := by nlinarith
  have hn3 : 0 < ((2 : ℚ) ^ b) ^ 3 - (2 : ℚ) ^ b := by nlinarith
  have hcube : (0 : ℚ) < ((2 : ℚ) ^ b) ^ 3 := by positivity
  have hd1 : 0 < a ^ 2 * (((2 : ℚ) ^ b) ^ 3 - (2 : ℚ) ^ b) + 3 * (((2 : ℚ) ^ b) ^ 3 * (m : ℚ)) := by
    nlinarith
  have hd2 : 0 < a ^ 2 + 3 * (m : ℚ) := by linarith
  have hpos : (0 : ℚ) < 3 * (m : ℚ) * a ^ 2 * (2 : ℚ) ^ b := by positivity
  rw [div_lt_div_iff₀ hd1 hd2]
  nlinarith [hpos]

/-! ## 5. Adversarial review: linear pool growth is excluded uniformly -/

/-- **No fixed-weight, linearly-growing channel pool fits the ladder.**  For every channel
weight `a ≠ 0` and every pool growth rate `κ > 0`, the law `ρ²(b) = a²/(a² + κ(b-1))` decays
too slowly from bitlen 44 to bitlen 88 to reproduce the recorded readings: the model's
`ρ²(88)/ρ²(44)` always exceeds the observed ratio `d88²/d44²`.  Cycle 1 proved the case
`κ = 1`; the whole two-parameter family falls. -/
theorem linear_pool_growth_excluded (a k : ℚ) (ha : a ≠ 0) (hk : 0 < k) :
    (a ^ 2 / (a ^ 2 + k * 43)) * d88 ^ 2 < (a ^ 2 / (a ^ 2 + k * 87)) * d44 ^ 2 := by
  have ha2 : 0 < a ^ 2 := by positivity
  have h1 : (0 : ℚ) < a ^ 2 + k * 43 := by nlinarith
  have h2 : (0 : ℚ) < a ^ 2 + k * 87 := by nlinarith
  have hd88 : d88 ^ 2 = 71289 / 250000 := by norm_num [d88]
  have hd44 : d44 ^ 2 = 1521 / 2500 := by norm_num [d44]
  rw [div_mul_eq_mul_div, div_mul_eq_mul_div, div_lt_div_iff₀ h1 h2, hd88, hd44]
  nlinarith

/-! ## 6. Model discrimination: `ρ²` scale versus odds scale -/

/-- The odds transform of a correlation reading. -/
def odds (r : ℚ) : ℚ := r ^ 2 / (1 - r ^ 2)

/-- The odds-scale rung invariant `odds(ρ)·b²` of the competing inverse-square hypothesis. -/
def oddsConst (b : ℕ) (r : ℚ) : ℚ := odds r * (b : ℚ) ^ 2

/-- The odds-scale inverse-square law also fits the ladder: all nine non-outlier rungs have
`odds(ρ)·b² ∈ [2700, 3450]`.  On the trend alone the two hypotheses are indistinguishable. -/
theorem odds_constant_window :
    (2700 : ℚ) ≤ oddsConst 44 d44 ∧ oddsConst 44 d44 ≤ 3450 ∧
    (2700 : ℚ) ≤ oddsConst 56 d56 ∧ oddsConst 56 d56 ≤ 3450 ∧
    (2700 : ℚ) ≤ oddsConst 64 d64 ∧ oddsConst 64 d64 ≤ 3450 ∧
    (2700 : ℚ) ≤ oddsConst 68 d68 ∧ oddsConst 68 d68 ≤ 3450 ∧
    (2700 : ℚ) ≤ oddsConst 72 d72 ∧ oddsConst 72 d72 ≤ 3450 ∧
    (2700 : ℚ) ≤ oddsConst 76 d76 ∧ oddsConst 76 d76 ≤ 3450 ∧
    (2700 : ℚ) ≤ oddsConst 80 d80 ∧ oddsConst 80 d80 ≤ 3450 ∧
    (2700 : ℚ) ≤ oddsConst 84 d84 ∧ oddsConst 84 d84 ≤ 3450 ∧
    (2700 : ℚ) ≤ oddsConst 88 d88 ∧ oddsConst 88 d88 ≤ 3450 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    norm_num [oddsConst, odds, d44, d56, d64, d68, d72, d76, d80, d84, d88]

/-- The pooled odds-scale constant. -/
def pooledK : ℚ :=
  (oddsConst 44 d44 + oddsConst 56 d56 + oddsConst 64 d64 + oddsConst 68 d68 +
    oddsConst 72 d72 + oddsConst 76 d76 + oddsConst 80 d80 + oddsConst 84 d84 +
    oddsConst 88 d88) / 9

lemma pooledK_bounds : (3053 : ℚ) < pooledK ∧ pooledK < 3054 := by
  constructor <;>
    norm_num [pooledK, oddsConst, odds, d44, d56, d64, d68, d72, d76, d80, d84, d88]

/-- **The odds law predicts the first band miss at the 84-rung.**  Its predicted odds clear the
floor's odds `121/279` at bitlen 80 and fail at bitlen 84. -/
theorem odds_law_predicts_miss_at_84 :
    odds bandFloor < pooledK / (80 : ℚ) ^ 2 ∧ pooledK / (84 : ℚ) ^ 2 < odds bandFloor := by
  have hb := pooledK_bounds
  have hfl : odds bandFloor = 121 / 279 := by norm_num [odds, bandFloor]
  rw [hfl]
  constructor
  · rw [lt_div_iff₀ (by norm_num)]
    linarith [hb.1]
  · rw [div_lt_iff₀ (by norm_num)]
    linarith [hb.2]

/-- **The odds-scale law is falsified by the 84-rung.**  It predicts a miss at 84, but the
recorded 84-rung held the band at `0.56 ≥ 0.55`.  The `ρ²`-scale inverse law of cycle 1, whose
crossing lies at `87.5`, passes the same test — so the ladder discriminates between the two
otherwise indistinguishable hypotheses, and selects the inverse-bitlen law on the `ρ²` scale. -/
theorem odds_law_falsified_by_the_84_rung :
    pooledK / (84 : ℚ) ^ 2 < odds bandFloor ∧ odds bandFloor ≤ odds d84 := by
  refine ⟨odds_law_predicts_miss_at_84.2, ?_⟩
  norm_num [odds, bandFloor, d84]

/-- **The effective noise pool grows superlinearly.**  Model-independently within the dilution
family (the fitted pool size is `a²·(1 - ρ²)/ρ²`, whose *ratio* between two rungs does not
depend on `a`), the pool grows by a factor in `(3.8, 4)` between bitlen 44 and bitlen 88 —
while the bitlen merely doubles, and a linear pool would grow by `87/43 < 2.03`.  This is the
quantitative content of "super-dilute", and the reason `linear_pool_growth_excluded` holds. -/
theorem effective_pool_superlinear :
    (38 : ℚ) / 10 * odds d88 < odds d44 ∧ odds d44 < 4 * odds d88 ∧ (87 : ℚ) / 43 < 203 / 100 := by
  refine ⟨?_, ?_, ?_⟩ <;> norm_num [odds, d44, d88]

end Catalog.Pythagorean.ZeroFitDialProductLaw88