/-
# The abelian ladder: full pinning for maximal real cyclotomic fields, and the degree-nine rung

Let `ℓ` be an odd prime and `K = ℚ(ζ_ℓ)⁺` the maximal real subfield of the `ℓ`-th cyclotomic
field, a cyclic extension of degree `m = (ℓ - 1)/2` and conductor `ℓ`.  For a prime `p ≠ ℓ`
the *splitting type* of `p` in `K` is its residue degree `f(p)`, the order of `p` in
`(ℤ/ℓ)ˣ / {±1}`.  Since `(p^f)^2 = 1 ↔ p^f = ±1` in the field `𝔽_ℓ`, this is

  `f(p) = orderOf (p²)`  in the cyclic group `(ℤ/ℓ)ˣ` of order `2m`.

By Dirichlet/Chebotarev, `p mod ℓ` is uniformly distributed on `(ℤ/ℓ)ˣ`, so everything below
is a statement about the uniform measure on a cyclic group `G` of order `2m`.

Main results (all for an arbitrary cyclic group of even order `2m`, then specialised):

* `ForkPinning.card_orderOf_sq_eq` : exactly `2·φ(d)` elements `g` have `orderOf (g²) = d`,
  for every `d ∣ m` — **the splitting-type density law** `P(f = d) = φ(d)/m`.
* `ForkPinning.ladder_entropy` : `H(T) = ∑_{d ∣ m} -(φ(d)/m) log(φ(d)/m)`.
* `ForkPinning.ladder_full_pinning`, `ForkPinning.ladder_square_pins` : the residue (and
  already its square, i.e. its image in the Galois group `C_m`) pins the type completely:
  `I(p mod ℓ ; T) = H(T)`.
* `ForkPinning.sq_pow_eq_one_iff` : in a field, `(u²)^f = 1 ↔ u^f = 1 ∨ u^f = -1`, i.e. the type
  really is the order modulo `{±1}`.

Every rung: `ForkPinning.realCyclotomic_type_density` and `ForkPinning.realCyclotomic_type_entropy`
instantiate the law for `(ℤ/ℓ)ˣ`, every odd prime `ℓ`.

Degree-nine rung (`ℓ = 19`, `K = ℚ(ζ₁₉)⁺`, Galois group `C₉`):

* `ForkPinning.degreeNine_density_one/three/nine` : densities `1/9, 2/9, 6/9`.
* `ForkPinning.degreeNine_entropy` : `H(T) = (4/3) log 3 - (8/9) log 2` (exactly).
* `ForkPinning.degreeNine_entropy_bits` : `1.22439 < H(T)/log 2 < 1.22441` — the measured
  `1.2244` bits.
* `ForkPinning.degreeNine_full_pinning` : `I(p mod 19 ; T) = H(T)`.
-/

import Probability.ForkPinningCapacity

namespace ForkPinning

open Finset Real

/-! ## The splitting-type law in a cyclic group of even order -/

section Ladder

variable {G : Type*} [CommGroup G] [Fintype G] [DecidableEq G] [IsCyclic G]

/-- In a cyclic group of even order there are exactly two square roots of unity. -/
lemma card_sq_eq_one {m : ℕ} (hG : Fintype.card G = 2 * m) :
    #{g : G | g ^ 2 = 1} = 2 := by
  rw [← sum_card_orderOf_eq_card_pow_eq_one (by norm_num : (2 : ℕ) ≠ 0)]
  have h2 : Nat.divisors 2 = {1, 2} := by decide
  rw [h2, sum_pair (by norm_num),
    IsCyclic.card_orderOf_eq_totient (one_dvd _),
    IsCyclic.card_orderOf_eq_totient (by rw [hG]; exact dvd_mul_right 2 m)]
  simp

omit [IsCyclic G] in
/-- Every non-empty fibre of the squaring map is a translate of the kernel. -/
lemma card_sq_fiber (g₀ : G) :
    #{g : G | g ^ 2 = g₀ ^ 2} = #{g : G | g ^ 2 = 1} := by
  refine Finset.card_bij (fun g _ => g₀⁻¹ * g) (fun g hg => ?_) (fun g _ g' _ h => ?_)
    (fun g hg => ?_)
  · simp only [mem_filter, mem_univ, true_and] at hg ⊢
    rw [mul_pow, hg, inv_pow, inv_mul_cancel]
  · exact mul_left_cancel h
  · refine ⟨g₀ * g, ?_, by group⟩
    simp only [mem_filter, mem_univ, true_and] at hg ⊢
    rw [mul_pow, hg, mul_one]

omit [DecidableEq G] in
/-- In a cyclic group of order `2m`, every element killed by `m` is a square. -/
lemma exists_sq_of_pow_eq_one {m : ℕ} (hG : Fintype.card G = 2 * m) (s : G)
    (hs : s ^ m = 1) : ∃ g : G, g ^ 2 = s := by
  obtain ⟨γ, hγ⟩ := IsCyclic.exists_generator (α := G)
  have hord : orderOf γ = 2 * m := by
    rw [orderOf_eq_card_of_forall_mem_zpowers hγ, Nat.card_eq_fintype_card, hG]
  have hm : 0 < m := by
    have := Fintype.card_pos (α := G); omega
  obtain ⟨k, hk⟩ := (mem_powers_iff_mem_zpowers.mpr (hγ s) : s ∈ Submonoid.powers γ)
  simp only at hk
  have hdvd : 2 * m ∣ k * m := by
    rw [← hord, orderOf_dvd_iff_pow_eq_one, pow_mul, hk, hs]
  have h2k : 2 ∣ k := by
    obtain ⟨c, hc⟩ := hdvd
    refine ⟨c, ?_⟩
    have : k * m = (2 * c) * m := by rw [hc]; ring
    exact Nat.eq_of_mul_eq_mul_right hm this
  obtain ⟨j, rfl⟩ := h2k
  exact ⟨γ ^ j, by rw [← pow_mul, mul_comm, hk]⟩

omit [DecidableEq G] [IsCyclic G] in
/-- `orderOf (g²)` always divides `m` when `|G| = 2m`. -/
lemma orderOf_sq_dvd {m : ℕ} (hG : Fintype.card G = 2 * m) (g : G) : orderOf (g ^ 2) ∣ m := by
  rw [orderOf_dvd_iff_pow_eq_one, ← pow_mul, ← hG, pow_card_eq_one]

/-- **The splitting-type density law.**  In a cyclic group of order `2m`, for every `d ∣ m`
exactly `2·φ(d)` elements `g` have `orderOf (g²) = d`. -/
theorem card_orderOf_sq_eq {m d : ℕ} (hG : Fintype.card G = 2 * m) (hd : d ∣ m) :
    #{g : G | orderOf (g ^ 2) = d} = 2 * Nat.totient d := by
  have hdG : d ∣ Fintype.card G := hG ▸ Dvd.dvd.mul_left hd 2
  rw [card_eq_sum_card_fiberwise (f := fun g : G => g ^ 2) (t := {s : G | orderOf s = d})
    (fun g hg => by simpa using hg)]
  have hfib : ∀ s ∈ ({s : G | orderOf s = d} : Finset G),
      #{g ∈ ({g : G | orderOf (g ^ 2) = d} : Finset G) | g ^ 2 = s} = 2 := by
    intro s hs
    simp only [mem_filter, mem_univ, true_and] at hs
    have hsm : s ^ m = 1 := by rw [← orderOf_dvd_iff_pow_eq_one, hs]; exact hd
    obtain ⟨g₀, rfl⟩ := exists_sq_of_pow_eq_one hG s hsm
    have hset : ({g ∈ ({g : G | orderOf (g ^ 2) = orderOf (g₀ ^ 2)} : Finset G) |
        g ^ 2 = g₀ ^ 2} : Finset G) = ({g : G | g ^ 2 = g₀ ^ 2} : Finset G) := by
      ext g
      simp only [mem_filter, mem_univ, true_and, and_iff_right_iff_imp]
      intro hg; rw [hg]
    rw [← hs, hset, card_sq_fiber g₀, card_sq_eq_one hG]
  rw [sum_congr rfl hfib, sum_const, IsCyclic.card_orderOf_eq_totient hdG, smul_eq_mul,
    mul_comm]

/-- The splitting type `T(g) = orderOf (g²)`, as a statistic valued in the (finite) set of
divisors of `|G|`. -/
noncomputable def ladderType (g : G) : (Fintype.card G).divisors :=
  ⟨orderOf (g ^ 2), Nat.mem_divisors.mpr ⟨orderOf_dvd_card, Fintype.card_ne_zero⟩⟩

omit [IsCyclic G] [DecidableEq G] in
lemma fiber_ladderType (d : (Fintype.card G).divisors) :
    fiber ladderType d = ({g : G | orderOf (g ^ 2) = (d : ℕ)} : Finset G) := by
  ext g
  simp [fiber, ladderType, Subtype.ext_iff]

/-- **Density law, probabilistic form**: `P(T = d) = φ(d)/m` for `d ∣ m`. -/
theorem prb_ladderType {m : ℕ} (hG : Fintype.card G = 2 * m) (d : (Fintype.card G).divisors)
    (hd : (d : ℕ) ∣ m) : prb ladderType d = Nat.totient d / m := by
  have hm : (0 : ℝ) < m := by
    have := Fintype.card_pos (α := G)
    have : 0 < m := by omega
    exact_mod_cast this
  have hc : (Fintype.card G : ℝ) = 2 * m := by exact_mod_cast hG
  rw [prb, fiber_ladderType, card_orderOf_sq_eq hG hd, hc]
  push_cast
  field_simp

omit [IsCyclic G] [DecidableEq G] in
/-- Types not dividing `m` never occur. -/
theorem prb_ladderType_of_not_dvd {m : ℕ} (hG : Fintype.card G = 2 * m)
    (d : (Fintype.card G).divisors) (hd : ¬ (d : ℕ) ∣ m) : prb ladderType d = 0 := by
  rw [prb, fiber_ladderType]
  have : ({g : G | orderOf (g ^ 2) = (d : ℕ)} : Finset G) = ∅ := by
    ext g
    simp only [mem_filter, mem_univ, true_and, Finset.notMem_empty, iff_false]
    intro h
    exact hd (h ▸ orderOf_sq_dvd hG g)
  rw [this]
  simp

/-- **The ladder entropy law.**  The entropy of the splitting type of a cyclic extension of
degree `m` (realised inside a cyclic group of order `2m`) is the entropy of the totient
distribution `d ↦ φ(d)/m` on the divisors of `m`. -/
theorem ladder_entropy {m : ℕ} (hG : Fintype.card G = 2 * m) :
    H (ladderType : G → (Fintype.card G).divisors)
      = ∑ d ∈ m.divisors, negMulLog (Nat.totient d / m) := by
  have hm : m ≠ 0 := by
    have := Fintype.card_pos (α := G); omega
  set F : ℕ → ℝ := fun d => if d ∣ m then negMulLog (Nat.totient d / m) else 0 with hF
  have hterm : ∀ x : (Fintype.card G).divisors, negMulLog (prb ladderType x) = F x := by
    intro x
    by_cases hx : (x : ℕ) ∣ m
    · rw [hF]; dsimp only; rw [if_pos hx, prb_ladderType hG x hx]
    · rw [hF]; dsimp only; rw [if_neg hx, prb_ladderType_of_not_dvd hG x hx, negMulLog_zero]
  unfold H
  rw [Finset.sum_congr rfl (fun x _ => hterm x),
    Finset.sum_coe_sort (Fintype.card G).divisors F, hF, ← Finset.sum_filter]
  congr 1
  ext d
  simp only [mem_filter, Nat.mem_divisors]
  constructor
  · rintro ⟨_, h⟩; exact ⟨h, hm⟩
  · rintro ⟨h, _⟩
    exact ⟨⟨hG ▸ Dvd.dvd.mul_left h 2, Fintype.card_ne_zero⟩, h⟩

omit [IsCyclic G] in
/-- **Full pinning on every rung**: the residue pins the splitting type completely. -/
theorem ladder_full_pinning :
    mutualInfo (id : G → G) (ladderType : G → (Fintype.card G).divisors) = H (ladderType : G → (Fintype.card G).divisors) :=
  (pinned_iff_determines _ _).mpr (fun g g' h => by rw [show g = g' from h])

omit [IsCyclic G] in
/-- **Thickening is structural**: already the square `g²` (the image of the residue in the
Galois group `C_m = G/{±1}`) pins the type; the sign `±1` is pure thickening. -/
theorem ladder_square_pins :
    mutualInfo (fun g : G => g ^ 2) (ladderType : G → (Fintype.card G).divisors)
      = H (ladderType : G → (Fintype.card G).divisors) :=
  (pinned_iff_determines _ _).mpr (fun g g' h => by
    simp only [ladderType, Subtype.mk.injEq]; rw [h])

end Ladder

/-- In a field, the order of `u²` is the order of `u` modulo `{±1}`:
`(u²)^f = 1 ↔ u^f = ±1`. -/
theorem sq_pow_eq_one_iff {F : Type*} [Field F] (u : Fˣ) (f : ℕ) :
    (u ^ 2) ^ f = 1 ↔ u ^ f = 1 ∨ u ^ f = -1 := by
  rw [← pow_mul, mul_comm, pow_mul]
  constructor
  · intro h
    have h' : ((u ^ f : Fˣ) : F) ^ 2 = 1 := by
      have := congrArg (fun x : Fˣ => (x : F)) h
      simpa using this
    rw [pow_two] at h'
    rcases mul_self_eq_one_iff.mp h' with h1 | h1
    · left; exact Units.ext (by simpa using h1)
    · right; exact Units.ext (by simpa using h1)
  · rintro (h | h) <;> rw [h] <;> simp

/-! ## Every rung of the ladder: `ℚ(ζ_ℓ)⁺` for every odd prime `ℓ` -/

section AllRungs

variable (ℓ : ℕ) [Fact ℓ.Prime]

lemma card_units_zmod_prime (hℓ : ℓ ≠ 2) : Fintype.card (ZMod ℓ)ˣ = 2 * ((ℓ - 1) / 2) := by
  rw [ZMod.card_units_eq_totient, Nat.totient_prime (Fact.out : ℓ.Prime)]
  obtain ⟨k, hk⟩ := (Fact.out : ℓ.Prime).odd_of_ne_two hℓ
  omega

/-- **The density law on every rung.**  For every odd prime `ℓ` and every `d` dividing the
degree `m = (ℓ-1)/2` of `ℚ(ζ_ℓ)⁺`, the primes of residue degree `d` have density `φ(d)/m`. -/
theorem realCyclotomic_type_density (hℓ : ℓ ≠ 2)
    (d : (Fintype.card (ZMod ℓ)ˣ).divisors) (hd : (d : ℕ) ∣ (ℓ - 1) / 2) :
    prb (ladderType : (ZMod ℓ)ˣ → _) d = Nat.totient d / (((ℓ - 1) / 2 : ℕ) : ℝ) :=
  prb_ladderType (card_units_zmod_prime ℓ hℓ) d hd

/-- **The entropy law on every rung.** -/
theorem realCyclotomic_type_entropy (hℓ : ℓ ≠ 2) :
    H (ladderType : (ZMod ℓ)ˣ → _)
      = ∑ d ∈ ((ℓ - 1) / 2).divisors, negMulLog (Nat.totient d / (((ℓ - 1) / 2 : ℕ) : ℝ)) :=
  ladder_entropy (card_units_zmod_prime ℓ hℓ)

end AllRungs

/-! ## The degree-nine rung: `ℚ(ζ₁₉)⁺` -/

section DegreeNine

instance fact_prime_nineteen : Fact (Nat.Prime 19) := ⟨by norm_num⟩

lemma card_units_zmod19 : Fintype.card (ZMod 19)ˣ = 2 * 9 := by
  rw [ZMod.card_units_eq_totient, Nat.totient_prime fact_prime_nineteen.out]

/-- The splitting type of `p` in `ℚ(ζ₁₉)⁺`, read from `p mod 19`. -/
noncomputable abbrev T19 : (ZMod 19)ˣ → (Fintype.card (ZMod 19)ˣ).divisors := ladderType

lemma mem_div19 (d : ℕ) (hd : d ∣ 9) : d ∈ (Fintype.card (ZMod 19)ˣ).divisors := by
  rw [card_units_zmod19]
  exact Nat.mem_divisors.mpr ⟨Dvd.dvd.mul_left hd 2, by norm_num⟩

lemma totient_nine : Nat.totient 9 = 6 := by
  rw [show (9 : ℕ) = 3 ^ 2 by norm_num, Nat.totient_prime_pow (by norm_num) (by norm_num)]
  norm_num

lemma totient_three : Nat.totient 3 = 2 := by
  rw [Nat.totient_prime (by norm_num)]

/-- Split primes (`f = 1`): density `1/9`. -/
theorem degreeNine_density_one :
    prb T19 ⟨1, mem_div19 1 (one_dvd 9)⟩ = 1 / 9 := by
  rw [prb_ladderType card_units_zmod19 _ (one_dvd 9)]
  simp

/-- Primes splitting into three primes of degree three (`f = 3`): density `2/9`. -/
theorem degreeNine_density_three :
    prb T19 ⟨3, mem_div19 3 (by norm_num)⟩ = 2 / 9 := by
  rw [prb_ladderType card_units_zmod19 _ (by norm_num : (3 : ℕ) ∣ 9)]
  simp [totient_three]

/-- Inert primes (`f = 9`): density `6/9`. -/
theorem degreeNine_density_nine :
    prb T19 ⟨9, mem_div19 9 dvd_rfl⟩ = 6 / 9 := by
  rw [prb_ladderType card_units_zmod19 _ dvd_rfl]
  simp [totient_nine]

/-- **Exact entropy of the degree-nine splitting type**: `H(T) = (4/3) log 3 - (8/9) log 2`. -/
theorem degreeNine_entropy : H T19 = 4 / 3 * Real.log 3 - 8 / 9 * Real.log 2 := by
  rw [ladder_entropy card_units_zmod19]
  have h9 : Nat.divisors 9 = {1, 3, 9} := by decide
  rw [h9, sum_insert (by decide), sum_pair (by decide), totient_three, totient_nine]
  simp only [Nat.totient_one, Nat.cast_one, Nat.cast_ofNat, negMulLog]
  have h1 : Real.log (1 / 9) = -(2 * Real.log 3) := by
    rw [one_div, Real.log_inv, show (9 : ℝ) = 3 ^ 2 by norm_num, Real.log_pow]; push_cast; ring
  have h2 : Real.log (2 / 9) = Real.log 2 - 2 * Real.log 3 := by
    rw [Real.log_div (by norm_num) (by norm_num), show (9 : ℝ) = 3 ^ 2 by norm_num,
      Real.log_pow]; push_cast; ring
  have h3 : Real.log (6 / 9) = Real.log 2 - Real.log 3 := by
    rw [show (6 / 9 : ℝ) = 2 / 3 by norm_num, Real.log_div (by norm_num) (by norm_num)]
  rw [h1, h2, h3]
  ring

set_option exponentiation.threshold 1100 in
/-- Rational bounds on `log 3 / log 2` from `2^1054 < 3^665` and `3^306 < 2^485`. -/
lemma log_three_div_log_two_bounds :
    (1054 : ℝ) / 665 < Real.log 3 / Real.log 2 ∧ Real.log 3 / Real.log 2 < 485 / 306 := by
  have hl2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hA : (1054 : ℝ) * Real.log 2 < 665 * Real.log 3 := by
    have h : ((2 : ℝ) ^ 1054) < (3 : ℝ) ^ 665 := by exact_mod_cast (by norm_num : (2 : ℕ) ^ 1054 < 3 ^ 665)
    have := Real.log_lt_log (by positivity) h
    rwa [Real.log_pow, Real.log_pow] at this
  have hB : (306 : ℝ) * Real.log 3 < 485 * Real.log 2 := by
    have h : ((3 : ℝ) ^ 306) < (2 : ℝ) ^ 485 := by exact_mod_cast (by norm_num : (3 : ℕ) ^ 306 < 2 ^ 485)
    have := Real.log_lt_log (by positivity) h
    rwa [Real.log_pow, Real.log_pow] at this
  constructor
  · rw [div_lt_div_iff₀ (by norm_num) hl2]; linarith
  · rw [div_lt_div_iff₀ hl2 (by norm_num)]; linarith

/-- **The measured value, certified**: `1.22439 < H(T) / log 2 < 1.22441` bits. -/
theorem degreeNine_entropy_bits :
    (1.22439 : ℝ) < H T19 / Real.log 2 ∧ H T19 / Real.log 2 < 1.22441 := by
  have hl2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hrw : H T19 / Real.log 2 = 4 / 3 * (Real.log 3 / Real.log 2) - 8 / 9 := by
    rw [degreeNine_entropy]; field_simp
  obtain ⟨h1, h2⟩ := log_three_div_log_two_bounds
  rw [hrw]
  constructor <;> nlinarith

/-- **Full pinning at degree nine**: `I(p mod 19 ; T) = H(T) = (4/3) log 3 - (8/9) log 2`. -/
theorem degreeNine_full_pinning :
    mutualInfo (id : (ZMod 19)ˣ → (ZMod 19)ˣ) T19 = 4 / 3 * Real.log 3 - 8 / 9 * Real.log 2 := by
  rw [ladder_full_pinning, degreeNine_entropy]

end DegreeNine

end ForkPinning