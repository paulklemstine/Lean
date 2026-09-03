import Mathlib
import Novelty.ZeroFitDialU64
import MachineLearning.ZeroFitDialUnif52

/-!
# The zero-fit dial against a *quadratic-residue* baseline at bitlen 48

## Research context (FACT round-52 #1, exp 517, `DIAL-HOLDS-UNIFORM-48`)

The measurement under study reports a Spearman rank correlation between the
zero-count statistic `T` (the number of trailing binary zeros, i.e. the 2-adic
valuation) and a downstream `rate`, on **uniform** draws at bitlen 48:

* seeds 20261080/81/82 give `0.777 / 0.755 / 0.801`, all inside the validation
  band `[0.55, 0.85]`;
* `T` beats the **bare QR-count** baseline by `+0.09` to `+0.13` on every seed.

All previous catalog work on the dial compares `T` against the *popcount*
baseline (`MachineLearning.ZeroFitDialUnif52.binomBlocks`) or against capped
versions of itself (`Cryptography.BalancedBKeyDialRobustness`).  The
quadratic-residue baseline is a genuinely different comparator: it is an
*arithmetic* statistic, read off Legendre symbols, and this file supplies its
tie geometry.

## Main results

* `cubeSum`, `tieCorr_eq_cubeSum`, `spearmanSq_of_cubeSum`,
  `spearmanSq_anti_cubeSum` — the *cube-sum calculus*: the tie ceiling of a
  profile is a strictly decreasing function of `Σⱼ mⱼ³` at fixed sample size.
  This is the tool that compares two baselines with the same `n`.
* `card_squares_eq_card_nonsquares_succ`, `legendre_profile` — the **arithmetic
  bridge**: for an odd prime `p = 2m+1` exactly `m+1` residues are squares and
  `m` are not; proved from the vanishing of the quadratic character sum.
  Hence the tie profile of the QR indicator is `qrBlocks m = [m, m+1]`.
* `qr_ceiling_exact` — the **prime-independence law**: the bare QR-count dial has
  tie ceiling `ρ² = 3/4` *exactly*, for every odd prime modulus.  Unlike the
  dyadic ceiling it does not depend on the modulus at all, and unlike the
  popcount ceiling it does not tend to `1`.
* `prodProfile`, `qrVecProfile`, `qrVec_ceiling` — the **multiplicative tower
  law** for the joint Legendre *vector* over several primes: by CRT the tie
  profile is a product profile, so `Σ mⱼ³` is multiplicative and the ceiling is
  `1 - (∏(mᵢ³+(mᵢ+1)³) - N)/(N³ - N)` with `N = ∏(2mᵢ+1)`.
* `mulBinom`, `qrCountProfile`, `qrCount_ceiling_le_qrVec` — the **counting
  collapse**: summing the Legendre vector into a *count* is a coarsening, hence
  can only lower the ceiling; the inequality is proved for an arbitrary list of
  primes from a cube-superadditivity induction.
* `qr_symbol_crossover` — the **crossover hierarchy** at bitlen 48: one QR symbol
  (`3/4`) and two QR symbols counted (`117/140`) sit *below* the dyadic ceiling,
  three counted symbols (`≈ 0.8828`) and two *vector* symbols (`51/56`) sit
  above it.  Three Legendre symbols are needed before a QR count can, on tie
  geometry alone, out-resolve the trailing-zero dial.
* `qrVec_replicate_ceiling`, `qrVec_replicate_ge` — the **replicated-symbol tower**: `r`
  Legendre symbols at the prime `3`, kept as a vector, have ceiling
  `1 - (9^r - 3^r)/(27^r - 3^r) ≥ 1 - 2·3^{-r}`, so the QR baseline is capped only in its
  bare, one-symbol form.
* `unif48_inside_band`, `unif48_seeds_below_tie_ceiling`,
  `qr_readings_below_qr_ceiling` — the recorded round-52 numbers checked against
  the two ceilings.
* `qr_headroom_lt_six_hundredths`, `recorded_gap_forces_slack` — the **gap law**:
  the entire tie-geometry advantage of `T` over the bare QR-count is
  `< 0.06` in `ρ`, while the recorded advantage is `≥ 0.09`; hence the QR reading
  must sit at least `0.03` below its own ceiling and the recorded advantage is
  *not* a tie-resolution artefact.
* `band_saturation_asymmetry` — the validation band `[0.55, 0.85]` is nearly
  saturating for the QR baseline (its ceiling is `√3/2 < 0.8661`) but leaves `T`
  more than `0.07` of headroom: the two dials are not calibrated on the same
  scale, which is exactly why a *fixed* band cannot be transported between them.

## The scientific payload

Two sharp negative results.

1. `recorded_gap_forces_slack`: tie granularity can buy at most `0.06` of the
   `T`-over-QR advantage, so the recorded `0.09 – 0.13` is signal, not geometry.
2. `qr_symbol_crossover`: the *bare* QR-count is structurally incapable of
   matching the dyadic dial — its ceiling `3/4` is below `6/7` for **every**
   modulus and every bitlen.  Improving the baseline requires more Legendre
   symbols, and the counting collapse (`qrCount_ceiling_le_qrVec`) shows that
   they must be kept as a vector, not summed, to gain the most.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64
open Catalog.MachineLearning.ZeroFitDialUnif52

namespace Catalog.Cryptography.ZeroFitDialQRUnif48

/-! ## 1. The cube-sum calculus -/

/-- `Σⱼ mⱼ³` of a tie profile: the only functional of the profile the Spearman
ceiling depends on, once the sample size is fixed. -/
def cubeSum (L : List ℕ) : ℕ := (L.map fun m => m ^ 3).sum

@[simp] lemma cubeSum_nil : cubeSum [] = 0 := rfl

@[simp] lemma cubeSum_cons (m : ℕ) (L : List ℕ) : cubeSum (m :: L) = m ^ 3 + cubeSum L := rfl

lemma cubeSum_append (A B : List ℕ) : cubeSum (A ++ B) = cubeSum A + cubeSum B := by
  simp [cubeSum]

/-- The Kendall tie correction is `(Σⱼ mⱼ³ - n)/12`. -/
lemma tieCorr_eq_cubeSum (L : List ℕ) : 12 * tieCorr L = (cubeSum L : ℚ) - (L.sum : ℚ) := by
  induction L with
  | nil => simp [tieCorr]
  | cons m L ih =>
      rw [tieCorr_cons, cubeSum_cons, List.sum_cons]
      push_cast at ih ⊢
      linarith

/-- The tie-attenuation law in cube-sum form. -/
theorem spearmanSq_of_cubeSum (L : List ℕ) (h : 2 ≤ L.sum) :
    spearmanSq L = 1 - ((cubeSum L : ℚ) - (L.sum : ℚ)) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) := by
  rw [spearmanSq_eq L h, ← tieCorr_eq_cubeSum]

/-- **Cube-sum monotonicity.**  At fixed sample size, a larger `Σⱼ mⱼ³` means a lower
ceiling.  Coarsening a statistic increases `Σⱼ mⱼ³`, so it can only attenuate. -/
theorem spearmanSq_anti_cubeSum {L M : List ℕ} (hsum : L.sum = M.sum) (h : 2 ≤ L.sum)
    (hc : cubeSum L ≤ cubeSum M) : spearmanSq M ≤ spearmanSq L := by
  have h2 : 2 ≤ M.sum := hsum ▸ h
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hn
  have hcq : ((cubeSum L : ℕ) : ℚ) ≤ ((cubeSum M : ℕ) : ℚ) := by exact_mod_cast hc
  rw [spearmanSq_of_cubeSum L h, spearmanSq_of_cubeSum M h2, ← hsum]
  have heq : ((cubeSum M : ℚ) - (L.sum : ℚ)) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ))
      - ((cubeSum L : ℚ) - (L.sum : ℚ)) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ))
      = ((cubeSum M : ℚ) - (cubeSum L : ℚ)) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) := by
    rw [div_sub_div_same]
    congr 1
    ring
  have hdiff : (0 : ℚ) ≤ ((cubeSum M : ℚ) - (cubeSum L : ℚ)) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) :=
    div_nonneg (by linarith) (le_of_lt hden)
  linarith

/-! ## 2. The Legendre tie profile of an odd prime modulus -/

/-- Tie profile of the quadratic-residue indicator modulo the odd prime `p = 2m+1`:
`m` non-residues (indicator `0`) and `m+1` squares (indicator `1`, the residue `0`
counting as a square). -/
def qrBlocks (m : ℕ) : List ℕ := [m, m + 1]

@[simp] lemma qrBlocks_sum (m : ℕ) : (qrBlocks m).sum = 2 * m + 1 := by
  simp [qrBlocks]; omega

@[simp] lemma qrBlocks_cubeSum (m : ℕ) : cubeSum (qrBlocks m) = m ^ 3 + (m + 1) ^ 3 := by
  simp [qrBlocks, cubeSum]

open scoped Classical in
/-- **Arithmetic bridge, character form.**  Modulo an odd prime there is exactly one more
square than non-square.  Proof: the quadratic character sums to zero, contributes `+1` on
each nonzero square, `-1` on each non-square and `0` at the origin. -/
theorem card_squares_eq_card_nonsquares_succ (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    ((univ : Finset (ZMod p)).filter fun a => IsSquare a).card
      = ((univ : Finset (ZMod p)).filter fun a => ¬ IsSquare a).card + 1 := by
  have hchar : ringChar (ZMod p) ≠ 2 := by
    rw [ZMod.ringChar_zmod_n]; exact hp
  set A := (univ : Finset (ZMod p)).filter (fun a => IsSquare a) with hA_def
  set B := (univ : Finset (ZMod p)).filter (fun a => ¬ IsSquare a) with hB_def
  have hsplit : ∑ a ∈ A, quadraticChar (ZMod p) a + ∑ a ∈ B, quadraticChar (ZMod p) a = 0 := by
    rw [hA_def, hB_def, Finset.sum_filter_add_sum_filter_not]
    exact quadraticChar_sum_zero hchar
  have hB : ∑ a ∈ B, quadraticChar (ZMod p) a = -(B.card : ℤ) := by
    have hval : ∀ a ∈ B, quadraticChar (ZMod p) a = -1 := by
      intro a ha
      rw [hB_def, mem_filter] at ha
      exact quadraticChar_neg_one_iff_not_isSquare.2 ha.2
    rw [Finset.sum_congr rfl hval, Finset.sum_const, nsmul_eq_mul]
    ring
  have h0A : (0 : ZMod p) ∈ A := by
    rw [hA_def, mem_filter]
    exact ⟨mem_univ _, IsSquare.zero⟩
  have hA : ∑ a ∈ A, quadraticChar (ZMod p) a = (A.card : ℤ) - 1 := by
    rw [← Finset.add_sum_erase A _ h0A, quadraticChar_zero]
    have hval : ∀ a ∈ A.erase 0, quadraticChar (ZMod p) a = 1 := by
      intro a ha
      have hne : a ≠ 0 := Finset.ne_of_mem_erase ha
      have hsq : IsSquare a := by
        have := Finset.mem_of_mem_erase ha
        rw [hA_def, mem_filter] at this
        exact this.2
      exact (quadraticChar_one_iff_isSquare hne).2 hsq
    rw [Finset.sum_congr rfl hval, Finset.sum_const, nsmul_eq_mul,
      Finset.card_erase_of_mem h0A]
    have hA1 : 1 ≤ A.card := Finset.card_pos.2 ⟨0, h0A⟩
    have : ((A.card - 1 : ℕ) : ℤ) = (A.card : ℤ) - 1 := by
      omega
    rw [this]
    ring
  have hcards : (A.card : ℤ) - 1 - (B.card : ℤ) = 0 := by
    rw [hA, hB] at hsplit; linarith
  omega

open scoped Classical in
/-- **Arithmetic bridge, counting form.**  Modulo the odd prime `p = 2m+1` there are `m`
non-residues and `m+1` squares. -/
theorem legendre_profile (m : ℕ) (hp : Nat.Prime (2 * m + 1)) :
    ((univ : Finset (ZMod (2 * m + 1))).filter fun a => ¬ IsSquare a).card = m ∧
      ((univ : Finset (ZMod (2 * m + 1))).filter fun a => IsSquare a).card = m + 1 := by
  haveI : Fact (Nat.Prime (2 * m + 1)) := ⟨hp⟩
  have hne : 2 * m + 1 ≠ 2 := by omega
  have hsucc := card_squares_eq_card_nonsquares_succ (2 * m + 1) hne
  have htot :
      ((univ : Finset (ZMod (2 * m + 1))).filter fun a => IsSquare a).card
        + ((univ : Finset (ZMod (2 * m + 1))).filter fun a => ¬ IsSquare a).card
        = 2 * m + 1 := by
    rw [Finset.card_filter_add_card_filter_not, Finset.card_univ, ZMod.card]
  omega

open scoped Classical in
/-- The tie profile `qrBlocks m` really is the profile of the QR indicator mod `2m+1`. -/
theorem qrBlocks_eq_legendre_profile (m : ℕ) (hp : Nat.Prime (2 * m + 1)) :
    qrBlocks m =
      [((univ : Finset (ZMod (2 * m + 1))).filter fun a => ¬ IsSquare a).card,
        ((univ : Finset (ZMod (2 * m + 1))).filter fun a => IsSquare a).card] := by
  obtain ⟨h1, h2⟩ := legendre_profile m hp
  rw [qrBlocks, h1, h2]

/-! ## 3. The prime-independence law -/

/-- **Prime independence.**  The bare QR-count dial has Spearman ceiling `ρ² = 3/4`
*exactly*, for every odd prime modulus `2m+1`.  The modulus cancels: the ceiling of a
balanced two-valued statistic is a pure combinatorial constant. -/
theorem qr_ceiling_exact (m : ℕ) (hm : 1 ≤ m) : spearmanSq (qrBlocks m) = 3 / 4 := by
  have hsum : 2 ≤ (qrBlocks m).sum := by rw [qrBlocks_sum]; omega
  have hx : (1 : ℚ) ≤ (m : ℚ) := by exact_mod_cast hm
  have hm0 : (0 : ℚ) < (m : ℚ) := by linarith
  rw [spearmanSq_of_cubeSum _ hsum, qrBlocks_sum, qrBlocks_cubeSum]
  have hpos : (0 : ℚ) < ((2 * m + 1 : ℕ) : ℚ) ^ 3 - ((2 * m + 1 : ℕ) : ℚ) := by
    push_cast
    nlinarith [mul_pos (mul_pos hm0 hm0) hm0, mul_pos hm0 hm0]
  have key : (((m ^ 3 + (m + 1) ^ 3 : ℕ) : ℚ) - ((2 * m + 1 : ℕ) : ℚ))
      / (((2 * m + 1 : ℕ) : ℚ) ^ 3 - ((2 * m + 1 : ℕ) : ℚ)) = 1 / 4 := by
    rw [div_eq_div_iff (ne_of_gt hpos) (by norm_num : (4 : ℚ) ≠ 0)]
    push_cast
    ring
  rw [key]
  norm_num

/-- Corollary: the bare QR-count ceiling is strictly below the dyadic ceiling, at every
bitlen and every modulus. -/
theorem qr_ceiling_lt_dyadic (m b : ℕ) (hm : 1 ≤ m) (hb : 1 ≤ b) :
    spearmanSq (qrBlocks m) < spearmanSq (dyadicBlocks b) := by
  rw [qr_ceiling_exact m hm]
  have := dyadic_ceiling_gt b hb
  linarith

/-! ## 4. The multiplicative tower: joint Legendre vectors -/

/-- The tie profile of a *pair* of independent statistics: all products of block sizes.
By CRT this is the profile of the Legendre vector over two coprime moduli. -/
def prodProfile (A B : List ℕ) : List ℕ := A.flatMap fun a => B.map fun b => a * b

lemma sum_map_mul (a : ℕ) (B : List ℕ) : (B.map fun b => a * b).sum = a * B.sum := by
  induction B with
  | nil => simp
  | cons b B ih => simp [ih, Nat.mul_add]

lemma cubeSum_map_mul (a : ℕ) (B : List ℕ) :
    cubeSum (B.map fun b => a * b) = a ^ 3 * cubeSum B := by
  induction B with
  | nil => simp [cubeSum]
  | cons b B ih =>
      simp only [List.map_cons, cubeSum_cons, ih, mul_pow]
      ring

@[simp] lemma prodProfile_sum (A B : List ℕ) : (prodProfile A B).sum = A.sum * B.sum := by
  induction A with
  | nil => simp [prodProfile]
  | cons a A ih =>
      simp only [prodProfile, List.flatMap_cons, List.sum_append, List.sum_cons] at *
      rw [sum_map_mul, ih]
      ring

@[simp] lemma prodProfile_cubeSum (A B : List ℕ) :
    cubeSum (prodProfile A B) = cubeSum A * cubeSum B := by
  induction A with
  | nil => simp [prodProfile, cubeSum]
  | cons a A ih =>
      simp only [prodProfile, List.flatMap_cons] at *
      rw [cubeSum_append, cubeSum_map_mul, ih, cubeSum_cons]
      ring

/-- The tie profile of the joint Legendre **vector** over the primes `2mᵢ+1`. -/
def qrVecProfile (ms : List ℕ) : List ℕ :=
  ms.foldr (fun m L => prodProfile (qrBlocks m) L) [1]

@[simp] lemma qrVecProfile_sum (ms : List ℕ) :
    (qrVecProfile ms).sum = (ms.map fun m => 2 * m + 1).prod := by
  induction ms with
  | nil => simp [qrVecProfile]
  | cons m ms ih =>
      have h : qrVecProfile (m :: ms) = prodProfile (qrBlocks m) (qrVecProfile ms) := rfl
      rw [h, prodProfile_sum, qrBlocks_sum, ih, List.map_cons, List.prod_cons]

@[simp] lemma qrVecProfile_cubeSum (ms : List ℕ) :
    cubeSum (qrVecProfile ms) = (ms.map fun m => m ^ 3 + (m + 1) ^ 3).prod := by
  induction ms with
  | nil => simp [qrVecProfile, cubeSum]
  | cons m ms ih =>
      have h : qrVecProfile (m :: ms) = prodProfile (qrBlocks m) (qrVecProfile ms) := rfl
      rw [h, prodProfile_cubeSum, qrBlocks_cubeSum, ih, List.map_cons, List.prod_cons]

/-- **Multiplicative tower law.**  For the joint Legendre vector over the primes `2mᵢ+1`
the ceiling is `1 - (C - N)/(N³ - N)` with `N = ∏(2mᵢ+1)` and `C = ∏(mᵢ³+(mᵢ+1)³)`; both
constituents are *multiplicative* over the primes, so there is no interaction term. -/
theorem qrVec_ceiling (ms : List ℕ) (h : 2 ≤ (ms.map fun m => 2 * m + 1).prod) :
    spearmanSq (qrVecProfile ms)
      = 1 - ((((ms.map fun m => m ^ 3 + (m + 1) ^ 3).prod : ℕ) : ℚ)
              - (((ms.map fun m => 2 * m + 1).prod : ℕ) : ℚ))
          / ((((ms.map fun m => 2 * m + 1).prod : ℕ) : ℚ) ^ 3
              - (((ms.map fun m => 2 * m + 1).prod : ℕ) : ℚ)) := by
  have hs : 2 ≤ (qrVecProfile ms).sum := by rw [qrVecProfile_sum]; exact h
  rw [spearmanSq_of_cubeSum _ hs, qrVecProfile_sum, qrVecProfile_cubeSum]

/-! ## 5. The counting collapse -/

/-- Add `x` to the head of a profile (or create it). -/
def addHead (x : ℕ) : List ℕ → List ℕ
  | [] => [x]
  | y :: t => (x + y) :: t

/-- Multiply the generating polynomial of a profile by `b + a·z`: this is the convolution
step that turns a QR *vector* profile into a QR *count* profile. -/
def mulBinom (a b : ℕ) : List ℕ → List ℕ
  | [] => []
  | c :: L => (b * c) :: addHead (a * c) (mulBinom a b L)

/-- The tie profile of the **count** of quadratic residues among the primes `2mᵢ+1`. -/
def qrCountProfile (ms : List ℕ) : List ℕ :=
  ms.foldr (fun m L => mulBinom m (m + 1) L) [1]

@[simp] lemma addHead_sum (x : ℕ) (L : List ℕ) : (addHead x L).sum = x + L.sum := by
  cases L with
  | nil => simp [addHead]
  | cons y t => simp [addHead]; omega

lemma mulBinom_sum (a b : ℕ) (L : List ℕ) : (mulBinom a b L).sum = (a + b) * L.sum := by
  induction L with
  | nil => simp [mulBinom]
  | cons c L ih =>
      simp only [mulBinom, List.sum_cons, addHead_sum, ih]
      ring

@[simp] lemma qrCountProfile_sum (ms : List ℕ) :
    (qrCountProfile ms).sum = (ms.map fun m => 2 * m + 1).prod := by
  induction ms with
  | nil => simp [qrCountProfile]
  | cons m ms ih =>
      simp only [qrCountProfile, List.foldr_cons, List.map_cons, List.prod_cons] at *
      rw [mulBinom_sum, ih]
      ring

/-- Merging mass into one class is cube-superadditive. -/
lemma cubeSum_addHead_ge (x : ℕ) (L : List ℕ) : x ^ 3 + cubeSum L ≤ cubeSum (addHead x L) := by
  cases L with
  | nil => simp [addHead]
  | cons y t =>
      simp only [addHead, cubeSum_cons]
      nlinarith [sq_nonneg x, sq_nonneg y, Nat.zero_le (x * y)]

/-- One convolution step can only increase the cube sum relative to the product profile. -/
lemma cubeSum_mulBinom_ge (a b : ℕ) (L : List ℕ) :
    (a ^ 3 + b ^ 3) * cubeSum L ≤ cubeSum (mulBinom a b L) := by
  induction L with
  | nil => simp [mulBinom]
  | cons c L ih =>
      have h1 : (a * c) ^ 3 + cubeSum (mulBinom a b L) ≤ cubeSum (addHead (a * c) (mulBinom a b L)) :=
        cubeSum_addHead_ge _ _
      have h2 : cubeSum (mulBinom a b (c :: L))
          = (b * c) ^ 3 + cubeSum (addHead (a * c) (mulBinom a b L)) := rfl
      have h3 : (a * c) ^ 3 = a ^ 3 * c ^ 3 := by ring
      have h4 : (b * c) ^ 3 = b ^ 3 * c ^ 3 := by ring
      rw [h2, cubeSum_cons]
      calc (a ^ 3 + b ^ 3) * (c ^ 3 + cubeSum L)
          = (a ^ 3 * c ^ 3 + b ^ 3 * c ^ 3) + (a ^ 3 + b ^ 3) * cubeSum L := by ring
        _ ≤ (a ^ 3 * c ^ 3 + b ^ 3 * c ^ 3) + cubeSum (mulBinom a b L) := by
              exact Nat.add_le_add_left ih _
        _ ≤ (b * c) ^ 3 + ((a * c) ^ 3 + cubeSum (mulBinom a b L)) := by
              rw [h3, h4]; omega
        _ ≤ (b * c) ^ 3 + cubeSum (addHead (a * c) (mulBinom a b L)) := by
              exact Nat.add_le_add_left h1 _

lemma qrCount_cubeSum_ge (ms : List ℕ) :
    cubeSum (qrVecProfile ms) ≤ cubeSum (qrCountProfile ms) := by
  induction ms with
  | nil => simp [qrVecProfile, qrCountProfile]
  | cons m ms ih =>
      have hstep := cubeSum_mulBinom_ge m (m + 1) (qrCountProfile ms)
      have hvec : cubeSum (qrVecProfile (m :: ms))
          = (m ^ 3 + (m + 1) ^ 3) * cubeSum (qrVecProfile ms) := by
        simp only [qrVecProfile, List.foldr_cons, prodProfile_cubeSum, qrBlocks_cubeSum]
      have hmono : (m ^ 3 + (m + 1) ^ 3) * cubeSum (qrVecProfile ms)
          ≤ (m ^ 3 + (m + 1) ^ 3) * cubeSum (qrCountProfile ms) :=
        Nat.mul_le_mul_left _ ih
      have hcount : cubeSum (qrCountProfile (m :: ms))
          = cubeSum (mulBinom m (m + 1) (qrCountProfile ms)) := rfl
      rw [hvec, hcount]
      exact le_trans hmono hstep

/-- **Counting collapse.**  Summing the Legendre vector into a QR *count* is a coarsening
of the tie partition, so the count baseline can never have a higher ceiling than the
vector baseline, for any list of prime moduli. -/
theorem qrCount_ceiling_le_qrVec (ms : List ℕ) (h : 2 ≤ (ms.map fun m => 2 * m + 1).prod) :
    spearmanSq (qrCountProfile ms) ≤ spearmanSq (qrVecProfile ms) := by
  refine spearmanSq_anti_cubeSum ?_ ?_ (qrCount_cubeSum_ge ms)
  · rw [qrVecProfile_sum, qrCountProfile_sum]
  · rw [qrVecProfile_sum]; exact h

/-! ## 6. The crossover hierarchy at bitlen 48 -/

lemma qrVecProfile_two : qrVecProfile [1, 2] = [2, 3, 4, 6] := by
  simp [qrVecProfile, prodProfile, qrBlocks]

lemma qrCountProfile_two : qrCountProfile [1, 2] = [6, 7, 2] := by
  simp [qrCountProfile, mulBinom, addHead]

lemma qrCountProfile_three : qrCountProfile [1, 2, 3] = [24, 46, 29, 6] := by
  simp [qrCountProfile, mulBinom, addHead]

lemma spearmanSq_qrVec_two : spearmanSq (qrVecProfile [1, 2]) = 51 / 56 := by
  rw [qrVecProfile_two, spearmanSq_of_cubeSum _ (by norm_num)]
  norm_num [cubeSum]

lemma spearmanSq_qrCount_two : spearmanSq (qrCountProfile [1, 2]) = 117 / 140 := by
  rw [qrCountProfile_two, spearmanSq_of_cubeSum _ (by norm_num)]
  norm_num [cubeSum]

lemma spearmanSq_qrCount_three : spearmanSq (qrCountProfile [1, 2, 3]) = 2433 / 2756 := by
  rw [qrCountProfile_three, spearmanSq_of_cubeSum _ (by norm_num)]
  norm_num [cubeSum]

/-- The bitlen-48 dyadic ceiling, bracketed. -/
lemma dyadic48_bracket :
    6 / 7 < spearmanSq (dyadicBlocks 48) ∧ spearmanSq (dyadicBlocks 48) < 6 / 7 + 1 / 10 ^ 14 := by
  refine ⟨dyadic_ceiling_gt 48 (by norm_num), ?_⟩
  have h := dyadic_ceiling_le 48 (by norm_num)
  have hsmall : (1 : ℚ) / 2 ^ 48 < 1 / 10 ^ 14 := by norm_num
  linarith

/-- **Crossover hierarchy.**  Against the bitlen-48 trailing-zero dial:
one Legendre symbol and two *counted* Legendre symbols have a strictly lower tie ceiling,
while three counted symbols, or two symbols kept as a vector, have a strictly higher one.
Three Legendre symbols are the threshold for a QR count to out-resolve `T`. -/
theorem qr_symbol_crossover :
    spearmanSq (qrBlocks 1) < spearmanSq (dyadicBlocks 48) ∧
    spearmanSq (qrCountProfile [1, 2]) < spearmanSq (dyadicBlocks 48) ∧
    spearmanSq (dyadicBlocks 48) < spearmanSq (qrCountProfile [1, 2, 3]) ∧
    spearmanSq (dyadicBlocks 48) < spearmanSq (qrVecProfile [1, 2]) := by
  obtain ⟨hlo, hhi⟩ := dyadic48_bracket
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [qr_ceiling_exact 1 le_rfl]; linarith
  · rw [spearmanSq_qrCount_two]; linarith
  · rw [spearmanSq_qrCount_three]; linarith
  · rw [spearmanSq_qrVec_two]; linarith

/-- The counting collapse is *strict* at two primes: `117/140 < 51/56`. -/
theorem qrCount_two_lt_qrVec_two :
    spearmanSq (qrCountProfile [1, 2]) < spearmanSq (qrVecProfile [1, 2]) := by
  rw [spearmanSq_qrCount_two, spearmanSq_qrVec_two]
  norm_num

/-! ## 6b. Growing the QR baseline: the replicated-symbol tower -/

lemma qrVec_replicate_sum (r : ℕ) :
    ((List.replicate r 1).map fun m => 2 * m + 1).prod = 3 ^ r := by
  induction r with
  | zero => simp
  | succ k ih => rw [List.replicate_succ, List.map_cons, List.prod_cons, ih]; ring

lemma qrVec_replicate_cubeSum (r : ℕ) :
    ((List.replicate r 1).map fun m => m ^ 3 + (m + 1) ^ 3).prod = 9 ^ r := by
  induction r with
  | zero => simp
  | succ k ih =>
      rw [List.replicate_succ, List.map_cons, List.prod_cons, ih]
      norm_num
      ring

/-- **Replicated-symbol tower.**  For `r` Legendre symbols at the prime `3`, kept as a vector,
the ceiling is `1 - (9^r - 3^r)/(27^r - 3^r)`: an explicit closed form in the number of
symbols. -/
theorem qrVec_replicate_ceiling (r : ℕ) (hr : 1 ≤ r) :
    spearmanSq (qrVecProfile (List.replicate r 1))
      = 1 - ((9 : ℚ) ^ r - 3 ^ r) / ((27 : ℚ) ^ r - 3 ^ r) := by
  have h2 : 2 ≤ (qrVecProfile (List.replicate r 1)).sum := by
    rw [qrVecProfile_sum, qrVec_replicate_sum]
    calc 2 ≤ 3 ^ 1 := by norm_num
      _ ≤ 3 ^ r := Nat.pow_le_pow_right (by norm_num) hr
  have hc : ((3 : ℚ) ^ r) ^ 3 = 27 ^ r := by
    rw [← pow_mul, mul_comm, pow_mul]; norm_num
  rw [spearmanSq_of_cubeSum _ h2, qrVecProfile_sum, qrVecProfile_cubeSum,
    qrVec_replicate_sum, qrVec_replicate_cubeSum]
  push_cast
  rw [hc]

/-- **Resolution growth.**  `r` Legendre symbols kept as a vector reach a ceiling of at least
`1 - 2·3^{-r}`: the QR baseline is not intrinsically capped, it is capped only when a single
symbol is used. -/
theorem qrVec_replicate_ge (r : ℕ) (hr : 1 ≤ r) :
    1 - 2 / (3 : ℚ) ^ r ≤ spearmanSq (qrVecProfile (List.replicate r 1)) := by
  rw [qrVec_replicate_ceiling r hr]
  have h3 : (3 : ℚ) ≤ 3 ^ r := by
    calc (3 : ℚ) = 3 ^ 1 := (pow_one 3).symm
      _ ≤ 3 ^ r := by apply pow_le_pow_right₀ (by norm_num) hr
  have h9 : ((3 : ℚ) ^ r) ^ 2 = 9 ^ r := by rw [← pow_mul, mul_comm, pow_mul]; norm_num
  have h27 : ((3 : ℚ) ^ r) ^ 3 = 27 ^ r := by rw [← pow_mul, mul_comm, pow_mul]; norm_num
  have hxpos : (0 : ℚ) < (3 : ℚ) ^ r := by positivity
  have hpos : (0 : ℚ) < 27 ^ r - 3 ^ r := by
    set x : ℚ := (3 : ℚ) ^ r with hx
    nlinarith
  have hkey : ((9 : ℚ) ^ r - 3 ^ r) / ((27 : ℚ) ^ r - 3 ^ r) ≤ 2 / (3 : ℚ) ^ r := by
    have hsplit : 2 / (3 : ℚ) ^ r - ((9 : ℚ) ^ r - 3 ^ r) / ((27 : ℚ) ^ r - 3 ^ r)
        = (2 * ((27 : ℚ) ^ r - 3 ^ r) - (3 : ℚ) ^ r * ((9 : ℚ) ^ r - 3 ^ r))
            / ((3 : ℚ) ^ r * ((27 : ℚ) ^ r - 3 ^ r)) :=
      div_sub_div _ _ (ne_of_gt hxpos) (ne_of_gt hpos)
    have hnum : 0 ≤ 2 * ((27 : ℚ) ^ r - 3 ^ r) - (3 : ℚ) ^ r * ((9 : ℚ) ^ r - 3 ^ r) := by
      set x : ℚ := (3 : ℚ) ^ r with hx
      nlinarith [sq_nonneg x, sq_nonneg (x - 1)]
    have hd : (0 : ℚ) < (3 : ℚ) ^ r * ((27 : ℚ) ^ r - 3 ^ r) := mul_pos hxpos hpos
    have hnn : 0 ≤ 2 / (3 : ℚ) ^ r - ((9 : ℚ) ^ r - 3 ^ r) / ((27 : ℚ) ^ r - 3 ^ r) := by
      rw [hsplit]
      exact div_nonneg hnum (le_of_lt hd)
    linarith
  linarith

/-- Two Legendre symbols, kept as a vector, already out-resolve the bitlen-48 dyadic dial. -/
theorem qrVec_two_symbols_beat_dyadic48 :
    spearmanSq (dyadicBlocks 48) < spearmanSq (qrVecProfile (List.replicate 2 1)) := by
  rw [qrVec_replicate_ceiling 2 (by norm_num)]
  have h : (1 : ℚ) - ((9 : ℚ) ^ 2 - 3 ^ 2) / ((27 : ℚ) ^ 2 - 3 ^ 2) = 9 / 10 := by norm_num
  rw [h]
  have hb := dyadic48_bracket.2
  linarith

/-! ## 7. The recorded round-52 numbers -/

/-- Seed 20261080. -/
def seed80 : ℚ := 777 / 1000
/-- Seed 20261081. -/
def seed81 : ℚ := 755 / 1000
/-- Seed 20261082. -/
def seed82 : ℚ := 801 / 1000
/-- Lower edge of the validation band. -/
def bandLow : ℚ := 55 / 100
/-- Upper edge of the validation band. -/
def bandHigh : ℚ := 85 / 100
/-- Lower edge of the recorded `T`-over-QR advantage. -/
def gapLow : ℚ := 9 / 100
/-- Upper edge of the recorded `T`-over-QR advantage. -/
def gapHigh : ℚ := 13 / 100

theorem unif48_inside_band :
    bandLow ≤ seed80 ∧ seed80 ≤ bandHigh ∧
    bandLow ≤ seed81 ∧ seed81 ≤ bandHigh ∧
    bandLow ≤ seed82 ∧ seed82 ≤ bandHigh := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> norm_num [seed80, seed81, seed82, bandLow, bandHigh]

/-- The seed spread is under `0.05`, i.e. the recorded seed-stability. -/
theorem unif48_seed_spread : seed82 - seed81 < 5 / 100 := by
  norm_num [seed81, seed82]

/-- Every recorded seed sits strictly below the bitlen-48 tie ceiling of `T`. -/
theorem unif48_seeds_below_tie_ceiling :
    seed80 ^ 2 < spearmanSq (dyadicBlocks 48) ∧
    seed81 ^ 2 < spearmanSq (dyadicBlocks 48) ∧
    seed82 ^ 2 < spearmanSq (dyadicBlocks 48) := by
  have hlo := dyadic48_bracket.1
  refine ⟨?_, ?_, ?_⟩
  · have h : seed80 ^ 2 < 6 / 7 := by norm_num [seed80]
    linarith
  · have h : seed81 ^ 2 < 6 / 7 := by norm_num [seed81]
    linarith
  · have h : seed82 ^ 2 < 6 / 7 := by norm_num [seed82]
    linarith

/-- Every QR-baseline reading compatible with the recorded advantage sits strictly below the
*QR* ceiling `3/4`, so the baseline reading is itself admissible. -/
theorem qr_readings_below_qr_ceiling (m : ℕ) (hm : 1 ≤ m) (q : ℚ)
    (hq : seed82 - gapHigh ≤ q) (hq' : q ≤ seed82 - gapLow) :
    q ^ 2 < spearmanSq (qrBlocks m) := by
  rw [qr_ceiling_exact m hm]
  have hs : seed82 = 801 / 1000 := rfl
  have hgl : gapLow = 9 / 100 := rfl
  have hgh : gapHigh = 13 / 100 := rfl
  rw [hs, hgh] at hq
  rw [hs, hgl] at hq'
  have h1 : (0 : ℚ) < q := by linarith
  have h2 : q ≤ 711 / 1000 := by linarith
  nlinarith

/-! ## 8. The gap law in real Spearman units -/

/-- `ρ` of the bitlen-48 dyadic profile is below `0.9259`. -/
theorem spearman_dyadic48_lt : spearman (dyadicBlocks 48) < 9259 / 10000 := by
  have hsum : 2 ≤ (dyadicBlocks 48).sum := by
    rw [dyadicBlocks_sum]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ 48 := Nat.pow_le_pow_right (by norm_num) (by norm_num)
  rw [spearman_eq_sqrt _ hsum]
  have hq : spearmanSq (dyadicBlocks 48) < 6 / 7 + 1 / 10 ^ 14 := dyadic48_bracket.2
  have hqr : ((spearmanSq (dyadicBlocks 48) : ℚ) : ℝ) < ((6 / 7 + 1 / 10 ^ 14 : ℚ) : ℝ) := by
    exact_mod_cast hq
  have hb : ((6 / 7 + 1 / 10 ^ 14 : ℚ) : ℝ) < ((9259 : ℝ) / 10000) ^ 2 := by
    push_cast
    norm_num
  calc Real.sqrt ((spearmanSq (dyadicBlocks 48) : ℚ) : ℝ)
      < Real.sqrt (((9259 : ℝ) / 10000) ^ 2) := by
        refine Real.sqrt_lt_sqrt ?_ (lt_trans hqr hb)
        exact_mod_cast spearmanSq_nonneg (dyadicBlocks 48)
    _ = 9259 / 10000 := Real.sqrt_sq (by norm_num)

/-- `ρ` of the QR profile is above `0.866`. -/
theorem spearman_qr_gt (m : ℕ) (hm : 1 ≤ m) : (866 : ℝ) / 1000 < spearman (qrBlocks m) := by
  have hsum : 2 ≤ (qrBlocks m).sum := by rw [qrBlocks_sum]; omega
  rw [spearman_eq_sqrt _ hsum, qr_ceiling_exact m hm]
  have h : ((866 : ℝ) / 1000) ^ 2 < ((3 / 4 : ℚ) : ℝ) := by norm_num
  calc (866 : ℝ) / 1000 = Real.sqrt (((866 : ℝ) / 1000) ^ 2) :=
        (Real.sqrt_sq (by norm_num)).symm
    _ < Real.sqrt (((3 / 4 : ℚ) : ℝ)) := Real.sqrt_lt_sqrt (by positivity) h

/-- **Headroom law.**  The entire tie-geometry advantage of `T` at bitlen 48 over the bare
QR-count is below `0.06` in Spearman units — for every odd prime modulus. -/
theorem qr_headroom_lt_six_hundredths (m : ℕ) (hm : 1 ≤ m) :
    spearman (dyadicBlocks 48) - spearman (qrBlocks m) < 6 / 100 := by
  have h1 := spearman_dyadic48_lt
  have h2 := spearman_qr_gt m hm
  have : (9259 : ℝ) / 10000 - 866 / 1000 < 6 / 100 := by norm_num
  linarith

/-- **The recorded gap forces slack.**  If the recorded `T` reading is at or below its own
tie ceiling and beats the QR baseline by at least `0.09`, then the QR reading must lie at
least `0.03` below the QR ceiling.  Tie geometry can supply at most two thirds of the
recorded advantage; the rest is response coupling. -/
theorem recorded_gap_forces_slack (m : ℕ) (hm : 1 ≤ m) (t q : ℝ)
    (ht : t ≤ spearman (dyadicBlocks 48)) (hgap : (9 : ℝ) / 100 ≤ t - q) :
    q ≤ spearman (qrBlocks m) - 3 / 100 := by
  have h := qr_headroom_lt_six_hundredths m hm
  linarith

/-- **Band-saturation asymmetry.**  The top of the validation band is within `0.017` of the
QR ceiling but more than `0.07` below the `T` ceiling: a band calibrated on `T` is nearly
unreachable for the QR baseline.  (`bandHigh = 0.85`.) -/
theorem band_saturation_asymmetry (m : ℕ) (hm : 1 ≤ m) :
    spearman (qrBlocks m) - ((bandHigh : ℝ)) < 17 / 1000 ∧
      7 / 100 < spearman (dyadicBlocks 48) - ((bandHigh : ℝ)) := by
  constructor
  · have hsum : 2 ≤ (qrBlocks m).sum := by rw [qrBlocks_sum]; omega
    have hle : spearman (qrBlocks m) < 8661 / 10000 := by
      rw [spearman_eq_sqrt _ hsum, qr_ceiling_exact m hm]
      have h : ((3 / 4 : ℚ) : ℝ) < ((8661 : ℝ) / 10000) ^ 2 := by norm_num
      calc Real.sqrt (((3 / 4 : ℚ) : ℝ)) < Real.sqrt (((8661 : ℝ) / 10000) ^ 2) :=
            Real.sqrt_lt_sqrt (by norm_num) h
        _ = 8661 / 10000 := Real.sqrt_sq (by norm_num)
    have hb : ((bandHigh : ℝ)) = 85 / 100 := by
      norm_num [bandHigh]
    rw [hb]; linarith
  · have hgt : (9258 : ℝ) / 10000 < spearman (dyadicBlocks 48) := by
      have hsum : 2 ≤ (dyadicBlocks 48).sum := by
        rw [dyadicBlocks_sum]
        calc 2 = 2 ^ 1 := rfl
          _ ≤ 2 ^ 48 := Nat.pow_le_pow_right (by norm_num) (by norm_num)
      rw [spearman_eq_sqrt _ hsum]
      have hlo : (6 : ℚ) / 7 < spearmanSq (dyadicBlocks 48) := dyadic48_bracket.1
      have hlor : ((6 / 7 : ℚ) : ℝ) < ((spearmanSq (dyadicBlocks 48) : ℚ) : ℝ) := by
        exact_mod_cast hlo
      have h : ((9258 : ℝ) / 10000) ^ 2 < ((6 / 7 : ℚ) : ℝ) := by norm_num
      calc (9258 : ℝ) / 10000 = Real.sqrt (((9258 : ℝ) / 10000) ^ 2) :=
            (Real.sqrt_sq (by norm_num)).symm
        _ < Real.sqrt (((spearmanSq (dyadicBlocks 48) : ℚ) : ℝ)) :=
            Real.sqrt_lt_sqrt (by positivity) (lt_trans h hlor)
    have hb : ((bandHigh : ℝ)) = 85 / 100 := by
      norm_num [bandHigh]
    rw [hb]; linarith

/-! ## 9. Bitlen stability of the envelope -/

/-- **Envelope flatness.**  Across the recorded deployment envelope (bitlens 44 – 52) the
dyadic tie ceiling is strictly decreasing but moves by less than `2⁻⁸⁰`, while the recorded
dial moves by tens of points.  The bitlen dependence of the dial is not tie geometry. -/
theorem envelope_ceiling_flat :
    spearmanSq (dyadicBlocks 52) < spearmanSq (dyadicBlocks 44) ∧
      spearmanSq (dyadicBlocks 44) - spearmanSq (dyadicBlocks 52) < 1 / 2 ^ 80 := by
  refine ⟨dyadic_ceiling_strict_anti (by norm_num) (by norm_num), ?_⟩
  have h1 := dyadic_ceiling_close 44 (by norm_num)
  have h2 := dyadic_ceiling_gt 52 (by norm_num)
  have h3 : ((1 : ℚ) / 4) ^ 44 < 1 / 2 ^ 80 := by norm_num
  linarith

end Catalog.Cryptography.ZeroFitDialQRUnif48