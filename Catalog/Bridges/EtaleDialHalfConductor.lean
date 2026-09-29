/-
# ETALE-DIAL II: the half-conductor law

`Bridges.EtaleDialVietaChannel` showed that at a prime-power conductor `ℓ^k` (`k ≥ 2`) the
hinted view `(p + q, p q) mod ℓ^k` does **not** determine the unordered residue pair
`{p, q} mod ℓ^k`.  This file measures exactly how much of the pair survives.

* `pow_dvd_mul_split` — the valuation pigeonhole: if `ℓ^k ∣ a b` and `2 j ≤ k + 1` then
  `ℓ^j ∣ a` or `ℓ^j ∣ b`.
* `half_conductor_law` — **the half-conductor law**: for *arbitrary* integers `p, q, p', q'`,
  if `ℓ^k` divides both `(p + q) - (p' + q')` and `p q - p' q'`, then the unordered pairs
  `{p, q}` and `{p', q'}` agree modulo `ℓ^⌈k/2⌉` (written `ℓ ^ ((k + 1) / 2)`).
* `half_conductor_sharp` — the law is **sharp**: the cells `{1, 1}` and
  `{1 + ℓ^j, 1 - ℓ^j}` (`j = ⌈k/2⌉`) have the same hinted view mod `ℓ^k` but do not agree
  modulo `ℓ^(j+1)` under either matching.
* `sumSufficient_reduction` / `not_sumSufficient_reduction_succ` — the same statement in the
  language of type maps on units: the reduction `(ZMod ℓ^k)ˣ → (ZMod ℓ^j)ˣ` is
  sum-sufficient, and the reduction to `(ZMod ℓ^(j+1))ˣ` is not (for `j + 1 ≤ k`).
* `SumSufficient.eq_of_sq_sub_eq_zero` — **square-zero rigidity** in any commutative ring: a
  sum-sufficient type map satisfies `f x = f y` whenever `(y - x)² = 0`.
* `sumSufficient_iff_factors_halfConductor` — **complete classification** at prime-power
  conductor: a type map on `(ZMod ℓ^k)ˣ` is sum-sufficient iff it only depends on the residue
  modulo `ℓ^⌈k/2⌉`.
* `refined_conductor_law`, `hensel_form` — **discriminant refinement**: if `ℓ^(t+1) ∤ p - q`
  the pair is determined modulo `ℓ^(k-t)`; in particular pairs with `p ≢ q (mod ℓ)` are
  determined modulo the full conductor (the Hensel phenomenon for simple roots).

For the D₄@8 dial (`ℓ = 2`, `k = 3`) the law says that the hinted view mod `8` carries the
pair exactly modulo `4`: it sees the `Q(i)` channel and nothing finer.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1, cycle 2): the collisions of cycle 1 are not random — the hinted view
  mod `ℓ^k` should see the pair to a definite "resolution" depending only on `k`.
Experiment (Stage 2, cycle 2): for each `m ∈ {8, 16, 32, 64, 9, 27, 25}` and each
  `r ∣ m` we tested whether `(p + q, p q) mod m` determines `{p, q} mod r` over all unit
  quadruples.  The maximal resolutions found were `8 → 4`, `16 → 4`, `32 → 8`, `64 → 8`,
  `9 → 3`, `27 → 9`, `25 → 5`: always `ℓ^⌈k/2⌉`.
Analysis (Stage 3, cycle 2): the identity `(p - p')(p - q') = p·Δs - Δn` reduces the
  question to a valuation pigeonhole; the sharpness witness is the nilpotent obstruction
  of cycle 1 at the first level where `a² ≡ 0`.
Critique (Stage 4, cycle 2): the integer statement needs no unit/coprimality hypothesis and
  holds for `ℓ = 2` as well; the unit statements are the arithmetic (unramified) reading.
-/
module

public import Mathlib
public import Bridges.EtaleDialVietaChannel

@[expose] public section

namespace EtaleDial

/-! ## 1. The valuation pigeonhole -/

/-- If `ℓ^k ∣ a b` and `2 j ≤ k + 1`, then `ℓ^j` divides one of the factors. -/
theorem pow_dvd_mul_split {ℓ : ℕ} [Fact ℓ.Prime] {k j : ℕ} (hjk : 2 * j ≤ k + 1) {a b : ℤ}
    (h : (ℓ : ℤ) ^ k ∣ a * b) : (ℓ : ℤ) ^ j ∣ a ∨ (ℓ : ℤ) ^ j ∣ b := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨ha, hb⟩ := hcon
  rw [padicValInt_dvd_iff] at ha hb h
  push_neg at ha hb
  rcases h with h | h
  · rcases mul_eq_zero.mp h with h | h
    · exact ha.1 h
    · exact hb.1 h
  · rw [padicValInt.mul ha.1 hb.1] at h
    omega

/-! ## 2. The half-conductor law -/

/-- **The half-conductor law.**  If two integer pairs have the same sum and the same product
modulo `ℓ^k`, then they agree as unordered pairs modulo `ℓ^⌈k/2⌉`. -/
theorem half_conductor_law {ℓ : ℕ} [Fact ℓ.Prime] (k : ℕ) {p q p' q' : ℤ}
    (hs : (ℓ : ℤ) ^ k ∣ (p + q) - (p' + q')) (hp : (ℓ : ℤ) ^ k ∣ p * q - p' * q') :
    ((ℓ : ℤ) ^ ((k + 1) / 2) ∣ p - p' ∧ (ℓ : ℤ) ^ ((k + 1) / 2) ∣ q - q') ∨
    ((ℓ : ℤ) ^ ((k + 1) / 2) ∣ p - q' ∧ (ℓ : ℤ) ^ ((k + 1) / 2) ∣ q - p') := by
  have key : (ℓ : ℤ) ^ k ∣ (p - p') * (p - q') := by
    have e : (p - p') * (p - q') = p * ((p + q) - (p' + q')) - (p * q - p' * q') := by ring
    rw [e]
    exact dvd_sub (dvd_mul_of_dvd_right hs _) hp
  have hsj : (ℓ : ℤ) ^ ((k + 1) / 2) ∣ (p + q) - (p' + q') :=
    (pow_dvd_pow _ (by omega)).trans hs
  rcases pow_dvd_mul_split (j := (k + 1) / 2) (by omega) key with h | h
  · left
    refine ⟨h, ?_⟩
    have e : q - q' = ((p + q) - (p' + q')) - (p - p') := by ring
    rw [e]
    exact dvd_sub hsj h
  · right
    refine ⟨h, ?_⟩
    have e : q - p' = ((p + q) - (p' + q')) - (p - q') := by ring
    rw [e]
    exact dvd_sub hsj h

/-- `ℓ^(j+1)` never divides `± ℓ^j`. -/
theorem not_pow_succ_dvd_pow {ℓ : ℕ} (hℓ : ℓ.Prime) (j : ℕ) :
    ¬ (ℓ : ℤ) ^ (j + 1) ∣ (ℓ : ℤ) ^ j := by
  intro h
  have h' : ℓ ^ (j + 1) ∣ ℓ ^ j := by exact_mod_cast h
  have := (Nat.pow_dvd_pow_iff_le_right hℓ.one_lt).mp h'
  omega

/-- **Sharpness of the half-conductor law.**  With `a = ℓ^⌈k/2⌉`, the cells `{1, 1}` and
`{1 + a, 1 - a}` have the same sum and product modulo `ℓ^k`, yet they do not agree modulo
`ℓ^(⌈k/2⌉ + 1)` under either matching. -/
theorem half_conductor_sharp {ℓ : ℕ} (hℓ : ℓ.Prime) (k : ℕ) :
    let a : ℤ := (ℓ : ℤ) ^ ((k + 1) / 2)
    (ℓ : ℤ) ^ k ∣ (1 + 1) - ((1 + a) + (1 - a)) ∧
    (ℓ : ℤ) ^ k ∣ 1 * 1 - (1 + a) * (1 - a) ∧
    ¬ ((ℓ : ℤ) ^ ((k + 1) / 2 + 1) ∣ 1 - (1 + a)) ∧
    ¬ ((ℓ : ℤ) ^ ((k + 1) / 2 + 1) ∣ 1 - (1 - a)) := by
  intro a
  refine ⟨⟨0, by ring⟩, ?_, ?_, ?_⟩
  · have e : (1 : ℤ) * 1 - (1 + a) * (1 - a) = (ℓ : ℤ) ^ ((k + 1) / 2 * 2) := by
      simp only [a]; ring
    rw [e]
    exact pow_dvd_pow _ (by omega)
  · have e : (1 : ℤ) - (1 + a) = -(ℓ : ℤ) ^ ((k + 1) / 2) := by simp only [a]; ring
    rw [e, dvd_neg]
    exact not_pow_succ_dvd_pow hℓ _
  · have e : (1 : ℤ) - (1 - a) = (ℓ : ℤ) ^ ((k + 1) / 2) := by simp only [a]; ring
    rw [e]
    exact not_pow_succ_dvd_pow hℓ _

/-! ## 3. The unit-level reading: reduction maps as type maps -/

/-- Reduction of units `(ZMod n)ˣ → (ZMod d)ˣ` for `d ∣ n`. -/
def unitRed {n : ℕ} (d : ℕ) (hd : d ∣ n) : (ZMod n)ˣ →* (ZMod d)ˣ :=
  Units.map (ZMod.castHom hd (ZMod d)).toMonoidHom

/-- Integer representatives: `x = ((x.val : ℤ) : ZMod n)`. -/
theorem zmod_eq_intCast_val {n : ℕ} [NeZero n] (x : ZMod n) : ((x.val : ℤ) : ZMod n) = x := by
  simp

/-- The reduction of `x` is represented by the same integer. -/
theorem unitRed_coe {n d : ℕ} [NeZero n] (hd : d ∣ n) (x : (ZMod n)ˣ) :
    ((unitRed d hd x : (ZMod d)ˣ) : ZMod d) = (((x : ZMod n).val : ℤ) : ZMod d) := by
  simp only [unitRed, Units.coe_map, RingHom.toMonoidHom_eq_coe, MonoidHom.coe_coe,
    ZMod.castHom_apply]
  rw [Int.cast_natCast, ZMod.natCast_val]

/-- **Unit form of the half-conductor law.**  The reduction
`(ZMod ℓ^k)ˣ → (ZMod ℓ^⌈k/2⌉)ˣ` is a sum-sufficient type map. -/
theorem sumSufficient_reduction {ℓ : ℕ} [Fact ℓ.Prime] (k : ℕ) :
    SumSufficient (unitRed (n := ℓ ^ k) (ℓ ^ ((k + 1) / 2)) (pow_dvd_pow ℓ (by omega))) := by
  haveI : NeZero (ℓ ^ k) := ⟨pow_ne_zero _ (Fact.out : ℓ.Prime).ne_zero⟩
  intro p q p' q' hs hp
  set P : ℤ := ((p : ZMod (ℓ ^ k)).val : ℤ)
  set Q : ℤ := ((q : ZMod (ℓ ^ k)).val : ℤ)
  set P' : ℤ := ((p' : ZMod (ℓ ^ k)).val : ℤ)
  set Q' : ℤ := ((q' : ZMod (ℓ ^ k)).val : ℤ)
  have cast_dvd : ∀ {m : ℕ} {x y : ℤ}, ((x : ZMod m) = (y : ZMod m)) → (m : ℤ) ∣ x - y := by
    intro m x y h
    have := (ZMod.intCast_eq_intCast_iff_dvd_sub y x m).mp h.symm
    exact this
  have hs' : ((ℓ ^ k : ℕ) : ℤ) ∣ (P + Q) - (P' + Q') := by
    apply cast_dvd
    push_cast
    simp only [P, Q, P', Q', zmod_eq_intCast_val]
    exact hs
  have hp' : ((ℓ ^ k : ℕ) : ℤ) ∣ P * Q - P' * Q' := by
    apply cast_dvd
    push_cast
    simp only [P, Q, P', Q', zmod_eq_intCast_val]
    exact hp
  push_cast at hs' hp'
  have red : ∀ x y : (ZMod (ℓ ^ k))ˣ,
      (ℓ : ℤ) ^ ((k + 1) / 2) ∣ ((x : ZMod (ℓ ^ k)).val : ℤ) - ((y : ZMod (ℓ ^ k)).val : ℤ) →
      unitRed (n := ℓ ^ k) (ℓ ^ ((k + 1) / 2)) (pow_dvd_pow ℓ (by omega)) x =
      unitRed (n := ℓ ^ k) (ℓ ^ ((k + 1) / 2)) (pow_dvd_pow ℓ (by omega)) y := by
    intro x y hxy
    apply Units.ext
    rw [unitRed_coe, unitRed_coe]
    apply (ZMod.intCast_eq_intCast_iff_dvd_sub _ _ _).mpr
    push_cast
    exact (dvd_sub_comm).mp hxy
  rcases half_conductor_law k hs' hp' with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨red _ _ h1, red _ _ h2⟩
  · exact Or.inr ⟨red _ _ h1, red _ _ h2⟩

/-- **Unit form of sharpness.**  If `⌈k/2⌉ + 1 ≤ k`, the reduction
`(ZMod ℓ^k)ˣ → (ZMod ℓ^(⌈k/2⌉+1))ˣ` is *not* sum-sufficient. -/
theorem not_sumSufficient_reduction_succ {ℓ : ℕ} [hℓ : Fact ℓ.Prime] {k : ℕ}
    (hk : (k + 1) / 2 + 1 ≤ k) :
    ¬ SumSufficient (unitRed (n := ℓ ^ k) (ℓ ^ ((k + 1) / 2 + 1)) (pow_dvd_pow ℓ hk)) := by
  intro h
  set j := (k + 1) / 2
  set a : ZMod (ℓ ^ k) := ((ℓ ^ j : ℕ) : ZMod (ℓ ^ k))
  have ha2 : a * a = 0 := by
    simp only [a, ← Nat.cast_mul]
    rw [ZMod.natCast_eq_zero_iff, ← pow_add]
    exact pow_dvd_pow ℓ (by omega)
  let u : (ZMod (ℓ ^ k))ˣ := ⟨1 + a, 1 - a, by linear_combination -ha2, by linear_combination -ha2⟩
  let v : (ZMod (ℓ ^ k))ˣ := ⟨1 - a, 1 + a, by linear_combination -ha2, by linear_combination -ha2⟩
  have hs : ((1 : (ZMod (ℓ ^ k))ˣ) : ZMod (ℓ ^ k)) + ((1 : (ZMod (ℓ ^ k))ˣ) : ZMod (ℓ ^ k))
      = (u : ZMod (ℓ ^ k)) + (v : ZMod (ℓ ^ k)) := by
    simp only [Units.val_one, u, v]; ring
  have hp : ((1 : (ZMod (ℓ ^ k))ˣ) : ZMod (ℓ ^ k)) * ((1 : (ZMod (ℓ ^ k))ˣ) : ZMod (ℓ ^ k))
      = (u : ZMod (ℓ ^ k)) * (v : ZMod (ℓ ^ k)) := by
    simp only [Units.val_one, u, v]; linear_combination ha2
  -- reductions of `1 ± a` modulo `ℓ^(j+1)` are `1 ± ℓ^j ≠ 1`
  have hred : ∀ ε : ℤ, (ε = 1 ∨ ε = -1) → ∀ w : (ZMod (ℓ ^ k))ˣ,
      (w : ZMod (ℓ ^ k)) = 1 + ε * a →
      unitRed (n := ℓ ^ k) (ℓ ^ (j + 1)) (pow_dvd_pow ℓ hk) w ≠ 1 := by
    intro ε hε w hw hw1
    have hc := congrArg (fun z : (ZMod (ℓ ^ (j + 1)))ˣ => (z : ZMod (ℓ ^ (j + 1)))) hw1
    simp only [unitRed, Units.coe_map, RingHom.toMonoidHom_eq_coe, MonoidHom.coe_coe,
      Units.val_one] at hc
    rw [hw, map_add, map_one, map_mul, map_intCast] at hc
    have hca : (ZMod.castHom (pow_dvd_pow ℓ hk) (ZMod (ℓ ^ (j + 1)))) a
        = ((ℓ ^ j : ℕ) : ZMod (ℓ ^ (j + 1))) := by simp only [a, map_natCast]
    rw [hca] at hc
    have h0 : (ε : ZMod (ℓ ^ (j + 1))) * ((ℓ ^ j : ℕ) : ZMod (ℓ ^ (j + 1))) = 0 := by
      linear_combination hc
    have h0' : ((ε * (ℓ ^ j : ℕ) : ℤ) : ZMod (ℓ ^ (j + 1))) = 0 := by push_cast at h0 ⊢; exact h0
    rw [ZMod.intCast_zmod_eq_zero_iff_dvd] at h0'
    rcases hε with rfl | rfl
    · push_cast at h0'
      simp only [one_mul] at h0'
      exact not_pow_succ_dvd_pow hℓ.out j h0'
    · push_cast at h0'
      rw [neg_one_mul, dvd_neg] at h0'
      exact not_pow_succ_dvd_pow hℓ.out j h0'
  rcases h 1 1 u v hs hp with ⟨h1, _⟩ | ⟨h1, _⟩
  · exact hred 1 (Or.inl rfl) u (by simp [u]) (by rw [← h1, map_one])
  · exact hred (-1) (Or.inr rfl) v (by simp [v]; ring) (by rw [← h1, map_one])

/-! ## 4. Square-zero rigidity and the complete classification at prime-power conductor -/

/-- **Square-zero rigidity.**  In any commutative ring, a sum-sufficient type map is constant
along square-zero displacements: if `(y - x)² = 0` then `f x = f y`.  The witness is the
diagonal collision `{x, x} ~ {y, 2x - y}`. -/
theorem SumSufficient.eq_of_sq_sub_eq_zero {R : Type*} [CommRing R] {β : Type*}
    {f : Rˣ → β} (hf : SumSufficient f) {x y : Rˣ}
    (hxy : ((y : R) - x) * ((y : R) - x) = 0) : f x = f y := by
  set d : R := (y : R) - x
  -- `x - d` is a unit, with inverse `(x + d) x⁻²`
  let w : Rˣ := ⟨(x : R) - d, ((x : R) + d) * ((x⁻¹ : Rˣ) : R) * ((x⁻¹ : Rˣ) : R), by
      have hx : (x : R) * ((x⁻¹ : Rˣ) : R) = 1 := Units.mul_inv x
      linear_combination (((x⁻¹ : Rˣ) : R) * ((x⁻¹ : Rˣ) : R)) * (-hxy) +
        ((x : R) * ((x⁻¹ : Rˣ) : R) + 1) * hx, by
      have hx : (x : R) * ((x⁻¹ : Rˣ) : R) = 1 := Units.mul_inv x
      linear_combination (((x⁻¹ : Rˣ) : R) * ((x⁻¹ : Rˣ) : R)) * (-hxy) +
        ((x : R) * ((x⁻¹ : Rˣ) : R) + 1) * hx⟩
  have hy : (y : R) = x + d := by simp only [d]; ring
  have hs : (x : R) + x = (y : R) + (w : R) := by
    show (x : R) + x = y + ((x : R) - d); rw [hy]; ring
  have hp : (x : R) * x = (y : R) * (w : R) := by
    show (x : R) * x = y * ((x : R) - d); rw [hy]; linear_combination hxy
  rcases hf x x y w hs hp with ⟨h1, _⟩ | ⟨_, h2⟩
  · exact h1
  · exact h2

/-- In `ZMod ℓ^k`, residues that agree modulo `ℓ^⌈k/2⌉` differ by a square-zero element. -/
theorem sq_sub_eq_zero_of_unitRed_eq {ℓ : ℕ} [Fact ℓ.Prime] (k : ℕ) {x y : (ZMod (ℓ ^ k))ˣ}
    (h : unitRed (n := ℓ ^ k) (ℓ ^ ((k + 1) / 2)) (pow_dvd_pow ℓ (by omega)) x =
      unitRed (n := ℓ ^ k) (ℓ ^ ((k + 1) / 2)) (pow_dvd_pow ℓ (by omega)) y) :
    ((y : ZMod (ℓ ^ k)) - x) * ((y : ZMod (ℓ ^ k)) - x) = 0 := by
  haveI : NeZero (ℓ ^ k) := ⟨pow_ne_zero _ (Fact.out : ℓ.Prime).ne_zero⟩
  have hc := congrArg (fun z : (ZMod (ℓ ^ ((k + 1) / 2)))ˣ => (z : ZMod (ℓ ^ ((k + 1) / 2)))) h
  simp only [unitRed_coe] at hc
  have hd := (ZMod.intCast_eq_intCast_iff_dvd_sub _ _ _).mp hc
  push_cast at hd
  set D : ℤ := ((y : ZMod (ℓ ^ k)).val : ℤ) - ((x : ZMod (ℓ ^ k)).val : ℤ)
  have hD2 : ((ℓ ^ k : ℕ) : ℤ) ∣ D * D := by
    push_cast
    have : (ℓ : ℤ) ^ ((k + 1) / 2 + (k + 1) / 2) ∣ D * D := by
      rw [pow_add]; exact mul_dvd_mul hd hd
    exact (pow_dvd_pow _ (by omega)).trans this
  have hz : ((D * D : ℤ) : ZMod (ℓ ^ k)) = 0 := (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mpr hD2
  have hDc : ((D : ℤ) : ZMod (ℓ ^ k)) = (y : ZMod (ℓ ^ k)) - x := by
    simp [D]
  rw [← hDc, ← Int.cast_mul]
  exact hz

/-- **Classification of sum-sufficient type maps at prime-power conductor.**  A type map
`f : (ZMod ℓ^k)ˣ → β` is sum-sufficient iff it only depends on the residue modulo
`ℓ^⌈k/2⌉`.  For the D₄@8 dial (`ℓ = 2`, `k = 3`) this is "only `p mod 4` is visible". -/
theorem sumSufficient_iff_factors_halfConductor {ℓ : ℕ} [Fact ℓ.Prime] (k : ℕ) {β : Type*}
    (f : (ZMod (ℓ ^ k))ˣ → β) :
    SumSufficient f ↔ ∀ x y : (ZMod (ℓ ^ k))ˣ,
      unitRed (n := ℓ ^ k) (ℓ ^ ((k + 1) / 2)) (pow_dvd_pow ℓ (by omega)) x =
      unitRed (n := ℓ ^ k) (ℓ ^ ((k + 1) / 2)) (pow_dvd_pow ℓ (by omega)) y → f x = f y := by
  constructor
  · intro hf x y hxy
    exact hf.eq_of_sq_sub_eq_zero (sq_sub_eq_zero_of_unitRed_eq k hxy)
  · intro hfac p q p' q' hs hp
    rcases sumSufficient_reduction (ℓ := ℓ) k p q p' q' hs hp with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact Or.inl ⟨hfac _ _ h1, hfac _ _ h2⟩
    · exact Or.inr ⟨hfac _ _ h1, hfac _ _ h2⟩

/-! ## 5. The discriminant-refined law (Hensel form) -/

/-- If `ℓ^k ∣ A B` and `ℓ^(t+1) ∤ A` with `t ≤ k`, then `ℓ^(k-t) ∣ B`. -/
theorem pow_dvd_of_mul_of_not_dvd {ℓ : ℕ} [Fact ℓ.Prime] {k t : ℕ} (htk : t ≤ k) {A B : ℤ}
    (h : (ℓ : ℤ) ^ k ∣ A * B) (hA : ¬ (ℓ : ℤ) ^ (t + 1) ∣ A) : (ℓ : ℤ) ^ (k - t) ∣ B := by
  rw [padicValInt_dvd_iff] at hA h ⊢
  push_neg at hA
  by_cases hB : B = 0
  · exact Or.inl hB
  right
  rcases h with h | h
  · rcases mul_eq_zero.mp h with h | h
    · exact absurd h hA.1
    · exact absurd h hB
  · rw [padicValInt.mul hA.1 hB] at h
    omega

/-- **Discriminant-refined half-conductor law.**  If moreover `ℓ^(t+1) ∤ p - q`
(so the discriminant `(p - q)²` has small valuation), the hinted view mod `ℓ^k` determines
the unordered pair modulo `ℓ^(k - t)`. -/
theorem refined_conductor_law {ℓ : ℕ} [Fact ℓ.Prime] {k t : ℕ} (htk : t + 1 ≤ k)
    {p q p' q' : ℤ} (hD : ¬ (ℓ : ℤ) ^ (t + 1) ∣ p - q)
    (hs : (ℓ : ℤ) ^ k ∣ (p + q) - (p' + q')) (hp : (ℓ : ℤ) ^ k ∣ p * q - p' * q') :
    ((ℓ : ℤ) ^ (k - t) ∣ p - p' ∧ (ℓ : ℤ) ^ (k - t) ∣ q - q') ∨
    ((ℓ : ℤ) ^ (k - t) ∣ p - q' ∧ (ℓ : ℤ) ^ (k - t) ∣ q - p') := by
  have key : (ℓ : ℤ) ^ k ∣ (p - p') * (p - q') := by
    have e : (p - p') * (p - q') = p * ((p + q) - (p' + q')) - (p * q - p' * q') := by ring
    rw [e]
    exact dvd_sub (dvd_mul_of_dvd_right hs _) hp
  have key' : (ℓ : ℤ) ^ k ∣ (p - q') * (p - p') := by rw [mul_comm]; exact key
  have hskt : (ℓ : ℤ) ^ (k - t) ∣ (p + q) - (p' + q') := (pow_dvd_pow _ (by omega)).trans hs
  -- one of `p - p'`, `p - q'` is not divisible by `ℓ^(t+1)`
  have hone : ¬ (ℓ : ℤ) ^ (t + 1) ∣ p - p' ∨ ¬ (ℓ : ℤ) ^ (t + 1) ∣ p - q' := by
    by_contra hcon
    push_neg at hcon
    apply hD
    have hst : (ℓ : ℤ) ^ (t + 1) ∣ (p + q) - (p' + q') := (pow_dvd_pow _ htk).trans hs
    have e : p - q = (p - p') + (p - q') - ((p + q) - (p' + q')) := by ring
    rw [e]
    exact dvd_sub (dvd_add hcon.1 hcon.2) hst
  rcases hone with h | h
  · -- `p - q'` is divisible by `ℓ^(k-t)`: the swapped matching
    have hB := pow_dvd_of_mul_of_not_dvd (by omega) key h
    right
    refine ⟨hB, ?_⟩
    have e : q - p' = ((p + q) - (p' + q')) - (p - q') := by ring
    rw [e]
    exact dvd_sub hskt hB
  · have hB := pow_dvd_of_mul_of_not_dvd (by omega) key' h
    left
    refine ⟨hB, ?_⟩
    have e : q - q' = ((p + q) - (p' + q')) - (p - p') := by ring
    rw [e]
    exact dvd_sub hskt hB

/-- **Hensel form.**  If `p ≢ q (mod ℓ)` — a pair with unit discriminant — then the hinted
view modulo `ℓ^k` determines the unordered pair modulo the *full* conductor `ℓ^k`: no
information is lost at all.  All collisions of the half-conductor law come from pairs that
are congruent modulo `ℓ`. -/
theorem hensel_form {ℓ : ℕ} [Fact ℓ.Prime] {k : ℕ} (hk : 1 ≤ k) {p q p' q' : ℤ}
    (hD : ¬ (ℓ : ℤ) ∣ p - q)
    (hs : (ℓ : ℤ) ^ k ∣ (p + q) - (p' + q')) (hp : (ℓ : ℤ) ^ k ∣ p * q - p' * q') :
    ((ℓ : ℤ) ^ k ∣ p - p' ∧ (ℓ : ℤ) ^ k ∣ q - q') ∨
    ((ℓ : ℤ) ^ k ∣ p - q' ∧ (ℓ : ℤ) ^ k ∣ q - p') := by
  have := refined_conductor_law (t := 0) (by omega) (by simpa using hD) hs hp
  simpa using this

end EtaleDial