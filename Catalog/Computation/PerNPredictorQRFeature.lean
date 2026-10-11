/-
# The QR-count feature of the per-N predictor (paper 142, exp 472)

The minimal per-N predictor of exp 472 is

  `rate(N) ≈ β₀ + β₁ · QRcount(N)`,   `QRcount(N) = #{p ∈ S : N^((p-1)/2) ≡ 1 (mod p)}`,

with `S` the odd primes `≤ 100` (24 Euler-criterion tests).  This file is the
number-theoretic half of the Lean validation:

* `euler_test_iff_legendre` — the Euler-criterion test computes the Legendre symbol:
  `N^(p/2) = 1` in `ZMod p` iff `(N/p) = 1`; hence `qrCount` counts the primes of `S` at
  which `N` is a non-zero quadratic residue (`qrCount_eq_card_legendre`).
* `sum_qrInd` — exactly `(p − 1)/2` residues pass the test, so the per-prime feature has
  mean `(p−1)/(2p)` (it is *not* a fair coin: `0` always fails).
* `sum_sq_qrInd_centered` — its centred second moment is `(p² − 1)/(4p)`.
* **CRT orthogonality** (`sum_pi_sq_sum_centered`): over a complete product residue system
  the centred per-prime indicators are pairwise orthogonal, so the feature's variance is
  the *sum* of the per-prime variances (`qrCount_variance`), and its mean is the sum of
  the per-prime means (`qrCount_mean`).  This is what makes a single count a sufficient
  summary of the 24 bits for a linear predictor.
* **Barrier line (5): zero factor information** (`factor_blind_balance`).  For `N ≡ n ≢ 0`
  (mod `p`) the factorisations `n = x·y` split exactly evenly according to whether the
  factor `x` passes the Euler test: `(p−1)/2` each.  The feature, a function of the
  residues of `N`, therefore carries no information about the residue character of either
  factor; and the feature itself is multiplicative over the factors
  (`legendre_feature_mul`), so it sees only the product.

All definitions follow the catalog's `U065QRMixture` conventions (quadratic character on
`ZMod p`, product residue systems via `Fintype.piFinset`).
-/
import Mathlib

namespace PerNPredictor

open Finset

/-! ## The Euler-criterion test and the Legendre symbol -/

/-- The Euler-criterion test for `N` at the prime `p`. -/
def eulerPass (p : ℕ) (N : ℤ) : Prop := (N : ZMod p) ^ (p / 2) = 1

instance (p : ℕ) (N : ℤ) : Decidable (eulerPass p N) := by
  unfold eulerPass; infer_instance

/-- The QR-count feature: the number of primes of `S` whose Euler test `N` passes. -/
def qrCount (S : Finset ℕ) (N : ℤ) : ℕ := (S.filter (fun p => eulerPass p N)).card

/-- The 24 odd primes up to 100 used by the exp 472 predictor. -/
def oddPrimesTo100 : Finset ℕ := (range 101).filter (fun p => p.Prime ∧ p ≠ 2)

theorem card_oddPrimesTo100 : oddPrimesTo100.card = 24 := by
  decide

/-- **Euler's criterion as a feature extractor.** For an odd prime `p`, the test
`N^(p/2) = 1` in `ZMod p` holds iff the Legendre symbol `(N/p)` equals `1`. -/
theorem euler_test_iff_legendre {p : ℕ} [hp : Fact p.Prime] (hp2 : p ≠ 2) (N : ℤ) :
    eulerPass p N ↔ legendreSym p N = 1 := by
  haveI : Fact (2 < p) := ⟨lt_of_le_of_ne hp.out.two_le (Ne.symm hp2)⟩
  unfold eulerPass
  rw [← legendreSym.eq_pow]
  by_cases h0 : (N : ZMod p) = 0
  · have hl : legendreSym p N = 0 := (legendreSym.eq_zero_iff p N).mpr h0
    rw [hl]; simp
  · rcases legendreSym.eq_one_or_neg_one p h0 with h | h <;> rw [h]
    · simp
    · simp only [Int.reduceNeg, Int.cast_neg, Int.cast_one]
      constructor
      · intro h1; exact absurd h1 (ZMod.neg_one_ne_one)
      · intro h1; norm_num at h1

/-- `qrCount` counts the primes of `S` at which `N` is a non-zero quadratic residue. -/
theorem qrCount_eq_card_legendre (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2) (N : ℤ) :
    qrCount S N = (S.filter (fun p => jacobiSym N p = 1)).card := by
  unfold qrCount
  congr 1
  refine Finset.filter_congr (fun p hpS => ?_)
  haveI : Fact p.Prime := ⟨(hS p hpS).1⟩
  rw [← jacobiSym.legendreSym.to_jacobiSym]
  exact euler_test_iff_legendre (hS p hpS).2 N

/-- **Multiplicativity of the feature.** For `N = P·Q` the per-prime Legendre feature is
the product of the factors' features: it only sees the product. -/
theorem legendre_feature_mul (p : ℕ) [Fact p.Prime] (P Q : ℤ) :
    legendreSym p (P * Q) = legendreSym p P * legendreSym p Q :=
  legendreSym.mul p P Q

/-! ## Per-prime moments of the indicator -/

section PerPrime

variable {p : ℕ} [hp : Fact p.Prime]

/-- Real indicator of the Euler test on a residue `a`. -/
noncomputable def qrInd (p : ℕ) (a : ZMod p) : ℝ := if a ^ (p / 2) = 1 then 1 else 0

lemma ringChar_ne_two' (hp2 : p ≠ 2) : ringChar (ZMod p) ≠ 2 := by
  rw [ZMod.ringChar_zmod_n]; exact hp2

/-- The indicator expressed through the quadratic character: `(χ + χ²)/2`. -/
theorem qrInd_eq_char (hp2 : p ≠ 2) (a : ZMod p) :
    qrInd p a = (((quadraticChar (ZMod p) a : ℤ) : ℝ)
      + ((quadraticChar (ZMod p) a : ℤ) : ℝ) ^ 2) / 2 := by
  have hp3 : 3 ≤ p := lt_of_le_of_ne hp.out.two_le (Ne.symm hp2)
  unfold qrInd
  by_cases ha : a = 0
  · subst ha
    have : (0 : ZMod p) ^ (p / 2) ≠ 1 := by
      rw [zero_pow (by omega)]; exact zero_ne_one
    simp [this]
  · have heul : a ^ (p / 2) = 1 ↔ quadraticChar (ZMod p) a = 1 := by
      rw [quadraticChar_one_iff_isSquare ha]
      exact ((ZMod.euler_criterion p ha)).symm
    rcases quadraticChar_dichotomy (F := ZMod p) ha with h | h
    · rw [if_pos (heul.mpr h), h]; norm_num
    · have : ¬ a ^ (p / 2) = 1 := by rw [heul, h]; decide
      rw [if_neg this, h]; norm_num

lemma sum_char_real (hp2 : p ≠ 2) :
    ∑ a : ZMod p, ((quadraticChar (ZMod p) a : ℤ) : ℝ) = 0 := by
  have := quadraticChar_sum_zero (F := ZMod p) (ringChar_ne_two' hp2)
  exact_mod_cast congrArg (fun z : ℤ => (z : ℝ)) this

lemma sum_char_sq_real :
    ∑ a : ZMod p, ((quadraticChar (ZMod p) a : ℤ) : ℝ) ^ 2 = p - 1 := by
  have h0 : ∀ a : ZMod p, ((quadraticChar (ZMod p) a : ℤ) : ℝ) ^ 2
      = 1 - (if a = 0 then (1 : ℝ) else 0) := by
    intro a
    by_cases ha : a = 0
    · simp [ha]
    · simp only [ha, if_false, sub_zero]
      rcases quadraticChar_dichotomy (F := ZMod p) ha with h | h <;> rw [h] <;> norm_num
  simp only [h0]
  rw [Finset.sum_sub_distrib, Finset.sum_ite_eq' Finset.univ (0 : ZMod p) (fun _ => (1 : ℝ))]
  simp [ZMod.card p]

/-- **Exactly `(p−1)/2` residues pass the Euler test.** -/
theorem sum_qrInd (hp2 : p ≠ 2) : ∑ a : ZMod p, qrInd p a = ((p : ℝ) - 1) / 2 := by
  simp only [qrInd_eq_char hp2, ← Finset.sum_div, Finset.sum_add_distrib,
    sum_char_real hp2, sum_char_sq_real, zero_add]

/-- Mean of the per-prime feature over a full residue system: `(p−1)/(2p)`. -/
theorem mean_qrInd (hp2 : p ≠ 2) :
    (∑ a : ZMod p, qrInd p a) / p = ((p : ℝ) - 1) / (2 * p) := by
  rw [sum_qrInd hp2]; field_simp

/-- Per-prime mean `μ_p = (p−1)/(2p)`. -/
noncomputable def qrMean (p : ℕ) : ℝ := ((p : ℝ) - 1) / (2 * p)

omit hp in
lemma qrInd_sq (a : ZMod p) : qrInd p a ^ 2 = qrInd p a := by
  unfold qrInd; split_ifs <;> norm_num

/-- **Centred second moment** of the per-prime feature: `(p² − 1)/(4p)`. -/
theorem sum_sq_qrInd_centered (hp2 : p ≠ 2) :
    ∑ a : ZMod p, (qrInd p a - qrMean p) ^ 2 = ((p : ℝ) ^ 2 - 1) / (4 * p) := by
  have hp0 : (p : ℝ) ≠ 0 := by exact_mod_cast hp.out.ne_zero
  have hexp : ∀ a : ZMod p, (qrInd p a - qrMean p) ^ 2
      = (1 - 2 * qrMean p) * qrInd p a + qrMean p ^ 2 := fun a => by
    rw [sub_sq, qrInd_sq]; ring
  rw [Finset.sum_congr rfl (fun a _ => hexp a), Finset.sum_add_distrib, ← Finset.mul_sum,
    sum_qrInd hp2, Finset.sum_const, Finset.card_univ, ZMod.card, nsmul_eq_mul, qrMean]
  field_simp
  ring

/-- The centred per-prime feature sums to zero. -/
theorem sum_qrInd_centered (hp2 : p ≠ 2) :
    ∑ a : ZMod p, (qrInd p a - qrMean p) = 0 := by
  have hp0 : (p : ℝ) ≠ 0 := by exact_mod_cast hp.out.ne_zero
  rw [Finset.sum_sub_distrib, sum_qrInd hp2, Finset.sum_const, Finset.card_univ, ZMod.card,
    nsmul_eq_mul, qrMean]
  field_simp
  ring

end PerPrime

/-! ## CRT orthogonality over a product residue system -/

section Product

variable {ι : Type*} [Fintype ι] [DecidableEq ι] {Z : ι → Type*} [∀ i, Fintype (Z i)]

/-- Marginal law: a single coordinate of a uniformly enumerated product is uniform. -/
theorem sum_pi_coord (f : ∀ k, Z k → ℝ) (i : ι) :
    ∑ N : (∀ k, Z k), f i (N i)
      = (∑ a, f i a) * ∏ k ∈ univ.erase i, (Fintype.card (Z k) : ℝ) := by
  have h1 : ∀ N : (∀ k, Z k), f i (N i)
      = ∏ k, (if k = i then f k (N k) else 1) := fun N => by
    rw [Finset.prod_ite_eq' univ i (fun k => f k (N k))]; simp
  have key := Fintype.prod_sum (fun k (a : Z k) => if k = i then f k a else (1 : ℝ))
  simp only at key
  simp only [h1]
  rw [← key, ← Finset.mul_prod_erase univ _ (mem_univ i)]
  simp only [if_true]
  congr 1
  refine Finset.prod_congr rfl (fun k hk => ?_)
  simp [Finset.ne_of_mem_erase hk]

/-- Pairwise orthogonality: two distinct coordinates, one of them centred, are
uncorrelated over the product. -/
theorem sum_pi_cross_zero (f : ∀ k, Z k → ℝ) {i j : ι} (hij : i ≠ j)
    (hi : ∑ a, f i a = 0) :
    ∑ N : (∀ k, Z k), f i (N i) * f j (N j) = 0 := by
  have h1 : ∀ N : (∀ k, Z k), f i (N i) * f j (N j)
      = ∏ k, (if k = i ∨ k = j then f k (N k) else 1) := fun N => by
    rw [← Finset.mul_prod_erase univ _ (mem_univ i),
      ← Finset.mul_prod_erase (univ.erase i) _ (mem_erase.mpr ⟨hij.symm, mem_univ j⟩)]
    rw [if_pos (Or.inl rfl), if_pos (Or.inr rfl)]
    rw [Finset.prod_eq_one (fun k hk => ?_), mul_one]
    have hkj := Finset.ne_of_mem_erase hk
    have hki := Finset.ne_of_mem_erase (Finset.mem_of_mem_erase hk)
    rw [if_neg (by tauto)]
  have key := Fintype.prod_sum
    (fun k (a : Z k) => if k = i ∨ k = j then f k a else (1 : ℝ))
  simp only at key
  simp only [h1]
  rw [← key]
  exact Finset.prod_eq_zero (mem_univ i) (by simpa using hi)

/-- **CRT orthogonality / variance additivity.**  If every coordinate function is centred,
the second moment of their sum over the product is the sum of the per-coordinate second
moments, each weighted by the size of the other coordinates. -/
theorem sum_pi_sq_sum_centered (f : ∀ k, Z k → ℝ) (hf : ∀ i, ∑ a, f i a = 0) :
    ∑ N : (∀ k, Z k), (∑ i, f i (N i)) ^ 2
      = ∑ i, (∑ a, f i a ^ 2) * ∏ k ∈ univ.erase i, (Fintype.card (Z k) : ℝ) := by
  have hsq : ∀ N : (∀ k, Z k), (∑ i, f i (N i)) ^ 2
      = ∑ i, ∑ j, f i (N i) * f j (N j) := fun N => by
    rw [sq, Finset.sum_mul_sum]
  simp only [hsq]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  rw [Finset.sum_comm, ← Finset.add_sum_erase univ _ (mem_univ i)]
  rw [Finset.sum_eq_zero (fun j hj => sum_pi_cross_zero f
      (Ne.symm (Finset.ne_of_mem_erase hj)) (hf i)), add_zero]
  have := sum_pi_coord (fun k a => f k a ^ 2) i
  simpa [sq] using this

end Product

/-! ## Mean and variance of the QR-count feature over a CRT period -/

section QRCountMoments

variable {ι : Type*} [Fintype ι] [DecidableEq ι] (q : ι → ℕ) [hq : ∀ i, Fact (q i).Prime]

/-- **Mean of the QR count.**  Summed over a complete product residue system
`∏ ZMod (q i)` (≅ `ZMod (∏ q i)` by CRT), the QR-count feature totals
`∑ᵢ (qᵢ−1)/2 · ∏_{k≠i} q_k`, i.e. its mean is `∑ᵢ (qᵢ−1)/(2qᵢ)`. -/
theorem qrCount_mean (hq2 : ∀ i, q i ≠ 2) :
    ∑ N : (∀ k, ZMod (q k)), ∑ i, qrInd (q i) (N i)
      = ∑ i, (((q i : ℝ) - 1) / 2) * ∏ k ∈ univ.erase i, (q k : ℝ) := by
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  rw [sum_pi_coord (fun k a => qrInd (q k) a) i, sum_qrInd (hq2 i)]
  simp [ZMod.card]

/-- **Variance of the QR count.**  The centred QR count has second moment
`∑ᵢ (qᵢ²−1)/(4qᵢ) · ∏_{k≠i} q_k` over a CRT period: per-prime variances simply add. -/
theorem qrCount_variance (hq2 : ∀ i, q i ≠ 2) :
    ∑ N : (∀ k, ZMod (q k)), (∑ i, (qrInd (q i) (N i) - qrMean (q i))) ^ 2
      = ∑ i, (((q i : ℝ) ^ 2 - 1) / (4 * q i)) * ∏ k ∈ univ.erase i, (q k : ℝ) := by
  rw [sum_pi_sq_sum_centered (fun k a => qrInd (q k) a - qrMean (q k))
    (fun i => sum_qrInd_centered (hq2 i))]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  rw [sum_sq_qrInd_centered (hq2 i)]
  simp [ZMod.card]

/-- Normalised form: the per-`N` variance of the centred QR count is
`∑ᵢ (qᵢ² − 1)/(4qᵢ²)` — strictly below `|ι|/4`, the fair-coin value. -/
theorem qrCount_variance_normalized (hq2 : ∀ i, q i ≠ 2) :
    (∑ N : (∀ k, ZMod (q k)), (∑ i, (qrInd (q i) (N i) - qrMean (q i))) ^ 2)
        / ∏ k, (q k : ℝ)
      = ∑ i, ((q i : ℝ) ^ 2 - 1) / (4 * (q i : ℝ) ^ 2) := by
  rw [qrCount_variance q hq2, Finset.sum_div]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  have hqi : (q i : ℝ) ≠ 0 := by exact_mod_cast (hq i).out.ne_zero
  rw [← Finset.mul_prod_erase univ (fun k => (q k : ℝ)) (mem_univ i)]
  have hrest : ∏ k ∈ univ.erase i, (q k : ℝ) ≠ 0 :=
    Finset.prod_ne_zero_iff.mpr (fun k _ => by exact_mod_cast (hq k).out.ne_zero)
  field_simp

end QRCountMoments

/-! ## Barrier line (5): the feature carries zero factor information -/

section FactorBlind

variable {p : ℕ} [hp : Fact p.Prime]

lemma card_units_square (hp2 : p ≠ 2) :
    ((univ.filter (fun x : ZMod p => x ≠ 0 ∧ IsSquare x)).card : ℝ) = ((p : ℝ) - 1) / 2 := by
  have hp3 : 3 ≤ p := lt_of_le_of_ne hp.out.two_le (Ne.symm hp2)
  rw [← sum_qrInd hp2, Finset.card_filter]
  push_cast
  refine Finset.sum_congr rfl (fun a _ => ?_)
  unfold qrInd
  by_cases ha : a = 0
  · subst ha
    have : (0 : ZMod p) ^ (p / 2) ≠ 1 := by
      rw [zero_pow (by omega)]; exact zero_ne_one
    simp [this]
  · simp [ha, ZMod.euler_criterion p ha]

/-- **Factor blindness of the residue dial.**  Fix a non-zero residue `n` of `N` mod `p`.
Among the factorisations `n = x · y` in `ZMod p`, exactly `(p−1)/2` have a factor `x` that
passes the Euler test and exactly `(p−1)/2` have one that fails it.  So the feature (a
function of `N mod p`) is perfectly balanced over the residue character of the hidden
factor. -/
theorem factor_blind_balance (hp2 : p ≠ 2) {n : ZMod p} (hn : n ≠ 0) :
    ((univ.filter (fun xy : ZMod p × ZMod p => xy.1 * xy.2 = n ∧ IsSquare xy.1)).card : ℝ)
      = ((p : ℝ) - 1) / 2 ∧
    ((univ.filter (fun xy : ZMod p × ZMod p => xy.1 * xy.2 = n ∧ ¬ IsSquare xy.1)).card : ℝ)
      = ((p : ℝ) - 1) / 2 := by
  -- factorisations of `n` are parametrised by the non-zero first factor
  have hbij : ∀ P : ZMod p → Prop, [DecidablePred P] →
      (univ.filter (fun xy : ZMod p × ZMod p => xy.1 * xy.2 = n ∧ P xy.1)).card
        = (univ.filter (fun x : ZMod p => x ≠ 0 ∧ P x)).card := by
    intro P _
    refine Finset.card_bij (fun xy _ => xy.1) ?_ ?_ ?_
    · intro xy hxy
      simp only [mem_filter, mem_univ, true_and] at hxy ⊢
      refine ⟨fun h0 => hn ?_, hxy.2⟩
      rw [← hxy.1, h0, zero_mul]
    · intro a ha b hb hab
      have hab : a.1 = b.1 := hab
      simp only [mem_filter, mem_univ, true_and] at ha hb
      have ha0 : a.1 ≠ 0 := fun h0 => hn (by rw [← ha.1, h0, zero_mul])
      have h2 : a.2 = b.2 := by
        have : a.1 * a.2 = a.1 * b.2 := by rw [ha.1, hab, hb.1]
        exact mul_left_cancel₀ ha0 this
      exact Prod.ext hab h2
    · intro x hx
      simp only [mem_filter, mem_univ, true_and] at hx
      refine ⟨(x, x⁻¹ * n), ?_, rfl⟩
      simp only [mem_filter, mem_univ, true_and]
      exact ⟨by rw [← mul_assoc, mul_inv_cancel₀ hx.1, one_mul], hx.2⟩
  have hsq := card_units_square (p := p) hp2
  have htot : (univ.filter (fun x : ZMod p => x ≠ 0)).card = p - 1 := by
    rw [Finset.filter_ne' univ (0 : ZMod p), Finset.card_erase_of_mem (mem_univ _),
      Finset.card_univ, ZMod.card]
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := univ.filter (fun x : ZMod p => x ≠ 0)) (fun x => IsSquare x)
  rw [Finset.filter_filter, Finset.filter_filter, htot] at hsplit
  refine ⟨by rw [hbij (fun x => IsSquare x)]; exact hsq, ?_⟩
  rw [hbij (fun x => ¬ IsSquare x)]
  have hp1 : 1 ≤ p := hp.out.one_lt.le
  have hcast : ((univ.filter (fun x : ZMod p => x ≠ 0 ∧ IsSquare x)).card : ℝ)
      + ((univ.filter (fun x : ZMod p => x ≠ 0 ∧ ¬ IsSquare x)).card : ℝ) = (p : ℝ) - 1 := by
    rw [← Nat.cast_one, ← Nat.cast_sub hp1]; exact_mod_cast hsplit
  linarith

end FactorBlind

end PerNPredictor