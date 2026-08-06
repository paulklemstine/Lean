/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic
-/
import Computation.WallpaperRhythm.OrbitEntropy

/-!
# The orbit-Bernoulli model: entropy deficit per orbit

`Computation.WallpaperRhythm.OrbitEntropy` proves that a probability
distribution on the space of `G`-invariant binary patterns has Shannon entropy at
most the number of orbits (in bits), with equality exactly for the uniform
distribution.  That leaves open how much entropy is lost by a *biased* stylistic
model.  Here we settle this for the natural biased model: switch each orbit on
independently with probability `θ`.

## Main results

* `bernoulliWeight` — the product weight `∏ i, (if x i then θ else 1 - θ)` of a
  Boolean configuration `x : ι → Bool`.
* `sum_bernoulliWeight` — the weights sum to one.
* `sum_negMulLog_bernoulliWeight` — the exact entropy computation
  `∑ x, -w(x) log w(x) = |ι| · (negMulLog θ + negMulLog (1 - θ))`.
* `orbitBernoulli` — the induced distribution on `GroupInvariantPattern G α`,
  obtained by transporting the product weight along the orbit-space
  parametrization of invariant patterns.
* `entropyBits_orbitBernoulli` — its Shannon entropy is exactly
  `m · H₂(θ)` bits, where `m` is the number of orbits and `H₂` is the binary
  entropy function in bits.
* `binaryEntropyBits_le_one`, `binaryEntropyBits_eq_one_iff` — `H₂(θ) ≤ 1` with
  equality iff `θ = 1/2`.
* `entropyDeficit_orbitBernoulli` — the entropy deficit
  `m - H(P_θ)` equals `m · (1 - H₂(θ))`: stylistic bias costs a fixed number of
  bits *per orbit*.
* `entropyDeficit_eq_zero_iff` — for a nonempty orbit space the deficit vanishes
  exactly at `θ = 1/2`.
-/

namespace WallpaperRhythm
namespace BernoulliEntropy

open MulAction Finset OrbitCounting

/-! ## The Bernoulli product weight on Boolean configurations -/

/-- The probability of the configuration `x` when each coordinate is switched on
independently with probability `θ`. -/
noncomputable def bernoulliWeight {ι : Type*} [Fintype ι] (θ : ℝ) (x : ι → Bool) : ℝ :=
  ∏ i, (if x i then θ else 1 - θ)

theorem bernoulliWeight_nonneg {ι : Type*} [Fintype ι] {θ : ℝ} (h0 : 0 ≤ θ) (h1 : θ ≤ 1)
    (x : ι → Bool) : 0 ≤ bernoulliWeight θ x := by
  refine Finset.prod_nonneg fun i _ => ?_
  by_cases hx : x i = true
  · simp only [if_pos hx]
    exact h0
  · simp only [if_neg hx]
    linarith

/-- The Bernoulli weights form a probability distribution. -/
theorem sum_bernoulliWeight {ι : Type*} [Fintype ι] [DecidableEq ι] (θ : ℝ) :
    ∑ x : ι → Bool, bernoulliWeight θ x = 1 := by
  have key := Finset.prod_univ_sum (t := fun _ : ι => (Finset.univ : Finset Bool))
    (f := fun (_ : ι) (b : Bool) => if b then θ else 1 - θ)
  simp only [Fintype.piFinset_univ] at key
  simp only [bernoulliWeight]
  rw [← key]
  simp

theorem sum_split_bool (n : ℕ) (F : (Fin (n + 1) → Bool) → ℝ) :
    ∑ x : Fin (n + 1) → Bool, F x = ∑ b : Bool, ∑ y : Fin n → Bool, F (Fin.cons b y) := by
  rw [← Equiv.sum_comp (Fin.consEquiv (fun _ : Fin (n + 1) => Bool)) F, Fintype.sum_prod_type]
  rfl

theorem bernoulliWeight_cons (n : ℕ) (θ : ℝ) (b : Bool) (y : Fin n → Bool) :
    bernoulliWeight θ (Fin.cons b y) = (if b then θ else 1 - θ) * bernoulliWeight θ y := by
  simp [bernoulliWeight, Fin.prod_univ_succ]

/-- **Entropy of a Bernoulli product, indexed form.**  The unnormalized (natural
logarithm) Shannon entropy of the product weight on `Fin n → Bool` is `n` times
the binary entropy of `θ`. -/
theorem sum_negMulLog_bernoulliWeight_fin (n : ℕ) (θ : ℝ) :
    ∑ x : Fin n → Bool, Real.negMulLog (bernoulliWeight θ x)
      = n * (Real.negMulLog θ + Real.negMulLog (1 - θ)) := by
  induction n with
  | zero => simp [bernoulliWeight]
  | succ n ih =>
    rw [sum_split_bool]
    have hb : ∀ b : Bool, ∑ y : Fin n → Bool, Real.negMulLog (bernoulliWeight θ (Fin.cons b y))
        = Real.negMulLog (if b then θ else 1 - θ)
          + (if b then θ else 1 - θ) * (n * (Real.negMulLog θ + Real.negMulLog (1 - θ))) := by
      intro b
      have hy : ∀ y : Fin n → Bool, Real.negMulLog (bernoulliWeight θ (Fin.cons b y))
          = bernoulliWeight θ y * Real.negMulLog (if b then θ else 1 - θ)
            + (if b then θ else 1 - θ) * Real.negMulLog (bernoulliWeight θ y) := by
        intro y
        rw [bernoulliWeight_cons, Real.negMulLog_mul]
      rw [Finset.sum_congr rfl (fun y _ => hy y), Finset.sum_add_distrib,
        ← Finset.sum_mul, ← Finset.mul_sum, sum_bernoulliWeight, one_mul, ih]
    have hbt := hb true
    have hbf := hb false
    simp only [reduceIte] at hbt hbf
    rw [Fintype.sum_bool, hbt, hbf]
    push_cast
    ring

/-- **Entropy of a Bernoulli product.**  On any finite index type the product
weight has entropy `|ι|` times the binary entropy of `θ`. -/
theorem sum_negMulLog_bernoulliWeight {ι : Type*} [Fintype ι] [DecidableEq ι] (θ : ℝ) :
    ∑ x : ι → Bool, Real.negMulLog (bernoulliWeight θ x)
      = (Fintype.card ι : ℝ) * (Real.negMulLog θ + Real.negMulLog (1 - θ)) := by
  set n := Fintype.card ι with hn
  let e : ι ≃ Fin n := Fintype.equivFin ι
  let E : (ι → Bool) ≃ (Fin n → Bool) := Equiv.arrowCongr e (Equiv.refl Bool)
  have hb : ∀ x : ι → Bool, bernoulliWeight θ x = bernoulliWeight θ (E x) := by
    intro x
    simp only [bernoulliWeight]
    rw [← Equiv.prod_comp e.symm (fun i => if x i then θ else 1 - θ)]
    rfl
  rw [Fintype.sum_equiv E (fun x => Real.negMulLog (bernoulliWeight θ x))
    (fun y => Real.negMulLog (bernoulliWeight θ y)) (fun x => congrArg Real.negMulLog (hb x))]
  exact sum_negMulLog_bernoulliWeight_fin n θ

/-! ## The binary entropy function -/

/-- The binary entropy function, measured in bits. -/
noncomputable def binaryEntropyBits (θ : ℝ) : ℝ :=
  (Real.negMulLog θ + Real.negMulLog (1 - θ)) / Real.log 2

theorem log_two_pos : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)

/-- The two-point distribution attached to a bias `θ`. -/
noncomputable def biasDist (θ : ℝ) : Bool → ℝ := fun b => if b then θ else 1 - θ

theorem sum_biasDist (θ : ℝ) : ∑ b : Bool, biasDist θ b = 1 := by
  simp [biasDist]

theorem sum_negMulLog_biasDist (θ : ℝ) :
    ∑ b : Bool, Real.negMulLog (biasDist θ b)
      = Real.negMulLog θ + Real.negMulLog (1 - θ) := by
  simp [biasDist]

/-- **The binary entropy is at most one bit.** -/
theorem binaryEntropyBits_le_one {θ : ℝ} (h0 : 0 ≤ θ) (h1 : θ ≤ 1) :
    binaryEntropyBits θ ≤ 1 := by
  have hnn : ∀ b : Bool, 0 ≤ biasDist θ b := by
    intro b
    by_cases hb : b = true
    · simp only [biasDist, if_pos hb]
      exact h0
    · simp only [biasDist, if_neg hb]
      linarith
  have hkey := OrbitEntropy.sum_negMulLog_le_log_card (biasDist θ) hnn (sum_biasDist θ)
  rw [sum_negMulLog_biasDist] at hkey
  have hcard : (Fintype.card Bool : ℝ) = 2 := by simp
  rw [hcard] at hkey
  rw [binaryEntropyBits, div_le_one log_two_pos]
  exact hkey

/-- **Equality case:** the binary entropy is exactly one bit only for the
unbiased distribution. -/
theorem binaryEntropyBits_eq_one_iff {θ : ℝ} (h0 : 0 ≤ θ) (h1 : θ ≤ 1) :
    binaryEntropyBits θ = 1 ↔ θ = 1 / 2 := by
  have hnn : ∀ b : Bool, 0 ≤ biasDist θ b := by
    intro b
    by_cases hb : b = true
    · simp only [biasDist, if_pos hb]
      exact h0
    · simp only [biasDist, if_neg hb]
      linarith
  have hkey := OrbitEntropy.sum_negMulLog_eq_log_card_iff (biasDist θ) hnn (sum_biasDist θ)
  rw [sum_negMulLog_biasDist] at hkey
  have hcard : (Fintype.card Bool : ℝ) = 2 := by simp
  rw [hcard] at hkey
  rw [binaryEntropyBits, div_eq_one_iff_eq (ne_of_gt log_two_pos), hkey]
  constructor
  · intro h
    have := h true
    simpa [biasDist] using this.trans (by norm_num)
  · intro h b
    by_cases hb : b = true
    · simp only [biasDist, if_pos hb, h]
      norm_num
    · simp only [biasDist, if_neg hb, h]
      norm_num

/-! ## The orbit-Bernoulli distribution on invariant patterns -/

variable {G : Type*} [Group G] {α : Type*} [MulAction G α]

/-- **The orbit-Bernoulli model.**  Switch each orbit on independently with
probability `θ`; this induces a probability distribution on the space of
`G`-invariant patterns. -/
noncomputable def orbitBernoulli [Fintype α] (θ : ℝ) (f : GroupInvariantPattern G α) : ℝ :=
  bernoulliWeight θ ((InvariantPattern.quotientEquiv (orbitSetoid G α)).symm f)

theorem orbitBernoulli_nonneg [Fintype α] {θ : ℝ} (h0 : 0 ≤ θ) (h1 : θ ≤ 1)
    (f : GroupInvariantPattern G α) : 0 ≤ orbitBernoulli θ f :=
  bernoulliWeight_nonneg h0 h1 _

/-- The orbit-Bernoulli weights are a probability distribution. -/
theorem sum_orbitBernoulli [Fintype α] (θ : ℝ) :
    ∑ f : GroupInvariantPattern G α, orbitBernoulli θ f = 1 := by
  classical
  refine Eq.trans ?_ (sum_bernoulliWeight (ι := Quotient (orbitSetoid G α)) θ)
  exact Fintype.sum_equiv (InvariantPattern.quotientEquiv (orbitSetoid G α)).symm
    (fun f => orbitBernoulli θ f) (fun x => bernoulliWeight θ x) (fun _ => rfl)

theorem sum_negMulLog_orbitBernoulli [Fintype α] (θ : ℝ) :
    ∑ f : GroupInvariantPattern G α, Real.negMulLog (orbitBernoulli θ f)
      = (Nat.card (orbitRel.Quotient G α) : ℝ)
        * (Real.negMulLog θ + Real.negMulLog (1 - θ)) := by
  classical
  refine Eq.trans (Fintype.sum_equiv (InvariantPattern.quotientEquiv (orbitSetoid G α)).symm
    (fun f => Real.negMulLog (orbitBernoulli θ f))
    (fun x => Real.negMulLog (bernoulliWeight θ x)) (fun _ => rfl)) ?_
  rw [sum_negMulLog_bernoulliWeight]
  congr 2
  exact (Nat.card_eq_fintype_card).symm

/-- **Entropy of the orbit-Bernoulli model.**  The Shannon entropy, in bits, of the
orbit-Bernoulli distribution on `G`-invariant patterns is exactly the number of
orbits times the binary entropy of the bias. -/
theorem entropyBits_orbitBernoulli [Fintype α] (θ : ℝ) :
    OrbitEntropy.entropyBits (orbitBernoulli (G := G) (α := α) θ)
      = (Nat.card (orbitRel.Quotient G α) : ℝ) * binaryEntropyBits θ := by
  rw [OrbitEntropy.entropyBits_def, sum_negMulLog_orbitBernoulli, binaryEntropyBits,
    mul_div_assoc]

/-- **Entropy deficit per orbit.**  The gap between the uniform capacity (the orbit
count, in bits) and the entropy of the orbit-Bernoulli model is exactly the orbit
count times the per-orbit deficit `1 - H₂(θ)`. -/
theorem entropyDeficit_orbitBernoulli [Fintype α] (θ : ℝ) :
    (Nat.card (orbitRel.Quotient G α) : ℝ)
        - OrbitEntropy.entropyBits (orbitBernoulli (G := G) (α := α) θ)
      = (Nat.card (orbitRel.Quotient G α) : ℝ) * (1 - binaryEntropyBits θ) := by
  rw [entropyBits_orbitBernoulli]
  ring

/-- The deficit is nonnegative, in accordance with the maximum-entropy bound. -/
theorem entropyDeficit_nonneg [Fintype α] {θ : ℝ} (h0 : 0 ≤ θ) (h1 : θ ≤ 1) :
    0 ≤ (Nat.card (orbitRel.Quotient G α) : ℝ)
      - OrbitEntropy.entropyBits (orbitBernoulli (G := G) (α := α) θ) := by
  rw [entropyDeficit_orbitBernoulli]
  have h := binaryEntropyBits_le_one h0 h1
  have hm : (0 : ℝ) ≤ (Nat.card (orbitRel.Quotient G α) : ℝ) := Nat.cast_nonneg _
  nlinarith

/-- **The deficit vanishes exactly at the unbiased model.**  If there is at least
one orbit, the orbit-Bernoulli distribution attains the full capacity precisely
when `θ = 1/2`. -/
theorem entropyDeficit_eq_zero_iff [Fintype α] {θ : ℝ} (h0 : 0 ≤ θ) (h1 : θ ≤ 1)
    (hm : 0 < Nat.card (orbitRel.Quotient G α)) :
    OrbitEntropy.entropyBits (orbitBernoulli (G := G) (α := α) θ)
        = (Nat.card (orbitRel.Quotient G α) : ℝ) ↔ θ = 1 / 2 := by
  have hm0 : (0 : ℝ) < (Nat.card (orbitRel.Quotient G α) : ℝ) := by exact_mod_cast hm
  rw [entropyBits_orbitBernoulli]
  constructor
  · intro h
    refine (binaryEntropyBits_eq_one_iff h0 h1).mp ?_
    have := mul_left_cancel₀ (ne_of_gt hm0) (h.trans (mul_one _).symm)
    exact this
  · intro h
    rw [(binaryEntropyBits_eq_one_iff h0 h1).mpr h, mul_one]

end BernoulliEntropy
end WallpaperRhythm