/-
# SEPTIC-FRONTIER (paper 120): THE-FRAMEWORK-EXTENDS to degree 7

FACT round 34 reports that the splitting-type channel of `x⁷ - 3` carries a large
signal at moduli divisible by the conductor `7` and none at coprime moduli.  The
splitting field of `x⁷ - 3` has Galois group the Frobenius group
`F₄₂ = AGL(1,7) = {x ↦ a x + b : a ∈ (ℤ/7)ˣ, b ∈ ℤ/7}` acting on the seven roots
`ζ₇ʲ · 3^{1/7}`; by Chebotarev the Frobenius of an unramified prime `p` is uniformly
distributed on it, its linear part `a` is `p mod 7` (the Frobenius in `ℚ(ζ₇)`), and the
splitting type of `x⁷ - 3 mod p` is the cycle type of `x ↦ a x + b`.  The number-theoretic
input (Chebotarev, the Galois group) is *not* formalized; everything below is the exact
finite-group / information-theoretic content, built on the catalog framework
`CyclicTypeChannel.uEnt / condEnt / mutInfo`.

Main results.

* `condEnt_eq_uEnt_pair_sub`, `mutInfo_eq_add_sub_pair`, `mutInfo_comm` : chain rule and
  symmetry of the catalog's counting mutual information.
* `minimalPeriod_affMap`, `minimalPeriod_translation`, `card_fixed_affMap` : cycle structure
  of affine maps over any field — one fixed point and all other orbits of length
  `orderOf a` if `a ≠ 1`; all orbits of length `char K` for a non-trivial translation.
* `affType_faithful` / `septicType_faithful` : the type label is exactly the
  (fixed-point count, cycle length) cycle data of the affine permutation.
* `septic_type_entropy`, `septic_conductor_info` : for `F₄₂`,
  `H(T) = 4/21 + (6/7)·log₂3 + (1/6)·log₂7` and `I(T ; p mod 7) = 1/3 + log₂3`.
* `septic_conductor_eq_sextic` : `I(T ; p mod 7) = typeEntropy 6` — the degree-7 conductor
  signal **is** the degree-6 cyclic type channel.
* `agl_conductor_info` : the same law for **every prime degree** `q`:
  `I(T ; p mod q) = typeEntropy (q - 1)` for `AGL(1,q)`.
* `agl_residual`, `agl_type_entropy`, `agl_residual_le` : the exact residual
  `H(T | p mod q) = (q log₂ q - (q-1) log₂(q-1)) / (q(q-1)) ≤ log₂ q / (q-1)`.
* `one_le_typeEntropy_even`, `one_le_agl_conductor_info`, `agl_information_completeness` :
  for odd prime `q` the conductor signal is at least one bit and explains at least a
  `1 - log₂ q / (q - 1)` fraction of the type entropy.
* `septic_coprime_flat`, `agl_coprime_flat` : independent (linearly disjoint) cyclotomic
  coordinates carry zero information.
* `abelian_character_kills_translations` : every homomorphism from a group of affine
  permutations to an abelian group kills the translations, so abelian (cyclotomic) data
  only sees the linear part `a = p mod q`: the signal lives at `7 ∣ m`, and the ramified
  prime `3` is *not* a signal modulus.

The file does not use the Lean `module` header because the catalog files it builds on are
non-module files, which a `module` file cannot import.
-/
import Novelty.S3SignChannelUniversal
import Shared.CyclicTypeChannelValues

namespace SepticFrontier

open Finset CyclicTypeChannel S3SignChannelUniversal

variable {α β γ : Type*}

/-! ## 1. Chain rule for the counting entropy -/

section Chain

variable [DecidableEq β] [DecidableEq γ]

/-- **Chain rule**: `H(g | k) = H(g, k) - H(k)`. -/
theorem condEnt_eq_uEnt_pair_sub (s : Finset α) (g : α → β) (k : α → γ) :
    condEnt s g k = uEnt s (fun x => (g x, k x)) - uEnt s k := by
  have hfib : ∀ c, ∀ x ∈ {x ∈ s | k x = c},
      #{y ∈ {x ∈ s | k x = c} | g y = g x} = #{y ∈ s | (g y, k y) = (g x, k x)} := by
    intro c x hx
    rw [mem_filter] at hx
    congr 1; ext y; simp only [mem_filter, Prod.mk.injEq]; constructor
    · rintro ⟨⟨hy, hky⟩, hg⟩; exact ⟨hy, hg, hky.trans hx.2.symm⟩
    · rintro ⟨hy, hg, hky⟩; exact ⟨⟨hy, hky.trans hx.2⟩, hg⟩
  have hterm : ∀ c ∈ s.image k,
      ((#{x ∈ s | k x = c} : ℝ) / s.card) * uEnt {x ∈ s | k x = c} g
        = ((#{x ∈ s | k x = c} : ℝ) * Real.logb 2 (#{x ∈ s | k x = c} : ℝ)) / s.card
          - (∑ x ∈ {x ∈ s | k x = c},
              Real.logb 2 (#{y ∈ s | (g y, k y) = (g x, k x)} : ℝ)) / s.card := by
    intro c hc
    obtain ⟨a, ha, rfl⟩ := mem_image.1 hc
    have hpos : (0:ℝ) < #{x ∈ s | k x = k a} := by exact_mod_cast fiber_card_pos ha
    rw [uEnt, Finset.sum_congr rfl (fun x hx => by rw [hfib _ x hx])]
    field_simp
  rw [condEnt, Finset.sum_congr rfl hterm, sum_sub_distrib, ← sum_div, ← sum_div,
    ← sum_logb_fiber, Finset.sum_fiberwise_of_maps_to (fun x hx => mem_image_of_mem k hx)]
  rw [uEnt, uEnt]; ring

/-- `I(g ; k) = H(g) + H(k) - H(g, k)`. -/
theorem mutInfo_eq_add_sub_pair (s : Finset α) (g : α → β) (k : α → γ) :
    mutInfo s g k = uEnt s g + uEnt s k - uEnt s (fun x => (g x, k x)) := by
  rw [mutInfo, condEnt_eq_uEnt_pair_sub]; ring

omit [DecidableEq β] [DecidableEq γ] in
lemma uEnt_pair_swap [DecidableEq β] [DecidableEq γ] (s : Finset α) (g : α → β) (k : α → γ) :
    uEnt s (fun x => (k x, g x)) = uEnt s (fun x => (g x, k x)) := by
  unfold uEnt
  congr 2
  refine Finset.sum_congr rfl fun a _ => ?_
  congr 3
  ext y; simp only [mem_filter, Prod.mk.injEq]; tauto

/-- Mutual information is symmetric. -/
theorem mutInfo_comm (s : Finset α) (g : α → β) (k : α → γ) :
    mutInfo s g k = mutInfo s k g := by
  rw [mutInfo_eq_add_sub_pair, mutInfo_eq_add_sub_pair, uEnt_pair_swap]; ring

end Chain

/-! ## 2. Affine dynamics -/

section Affine

variable {K : Type*} [Field K] {a b : K}

/-- The affine map `x ↦ a x + b`; for `K = ℤ/q` these are the elements of `AGL(1,q)`. -/
def affMap (a b : K) : K → K := fun x => a * x + b

/-- The unique fixed point `b / (1 - a)` of `x ↦ a x + b` when `a ≠ 1`. -/
def affFix (a b : K) : K := b / (1 - a)

lemma affFix_spec (ha : a ≠ 1) : a * affFix a b + b = affFix a b := by
  have : (1 - a) ≠ 0 := sub_ne_zero.2 (Ne.symm ha)
  unfold affFix; field_simp; ring

lemma affMap_iterate_sub (a b x₀ : K) (h : a * x₀ + b = x₀) (k : ℕ) (x : K) :
    (affMap a b)^[k] x - x₀ = a ^ k * (x - x₀) := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ_apply', affMap]
    have : a * (affMap a b)^[k] x + b - x₀ = a * ((affMap a b)^[k] x - x₀) := by
      linear_combination h
    rw [this, ih]; ring

lemma affMap_iterate_one (b : K) (k : ℕ) (x : K) :
    (affMap 1 b)^[k] x = x + k * b := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ_apply', ih, affMap]; push_cast; ring

/-- A non-fixed point is `k`-periodic iff `a ^ k = 1`. -/
theorem affMap_isPeriodicPt_iff (ha : a ≠ 1) {x : K} (hx : x ≠ affFix a b) (k : ℕ) :
    Function.IsPeriodicPt (affMap a b) k x ↔ a ^ k = 1 := by
  have h := affMap_iterate_sub a b _ (affFix_spec ha) k x
  have hx' : x - affFix a b ≠ 0 := sub_ne_zero.2 hx
  unfold Function.IsPeriodicPt Function.IsFixedPt
  constructor
  · intro hk
    rw [hk] at h
    have : (a ^ k - 1) * (x - affFix a b) = 0 := by linear_combination -h
    exact sub_eq_zero.1 ((mul_eq_zero.1 this).resolve_right hx')
  · intro hk
    rw [hk, one_mul] at h
    exact sub_left_inj.1 h

theorem affMap_fixed_iff (ha : a ≠ 1) (x : K) : affMap a b x = x ↔ x = affFix a b := by
  constructor
  · intro h
    by_contra hx
    have := (affMap_isPeriodicPt_iff ha hx 1).1 (by simpa [Function.IsPeriodicPt,
      Function.IsFixedPt] using h)
    exact ha (by simpa using this)
  · rintro rfl; exact affFix_spec ha

/-- Every non-fixed point of `x ↦ a x + b` (`a ≠ 1`) has exact period `orderOf a`. -/
theorem minimalPeriod_affMap (ha : a ≠ 1) {x : K} (hx : x ≠ affFix a b) :
    Function.minimalPeriod (affMap a b) x = orderOf a :=
  Nat.dvd_antisymm
    ((affMap_isPeriodicPt_iff ha hx _).2 (pow_orderOf_eq_one a)).minimalPeriod_dvd
    (orderOf_dvd_of_pow_eq_one
      ((affMap_isPeriodicPt_iff ha hx _).1 (Function.isPeriodicPt_minimalPeriod _ _)))

/-- A non-trivial translation in characteristic `q` has all orbits of length `q`. -/
theorem minimalPeriod_translation (q : ℕ) [CharP K q] (hb : b ≠ 0) (x : K) :
    Function.minimalPeriod (affMap 1 b) x = q := by
  have key : ∀ k, Function.IsPeriodicPt (affMap 1 b) k x ↔ q ∣ k := by
    intro k
    unfold Function.IsPeriodicPt Function.IsFixedPt
    rw [affMap_iterate_one, add_eq_left, mul_eq_zero, CharP.cast_eq_zero_iff K q]
    simp [hb]
  exact Nat.dvd_antisymm ((key q).2 dvd_rfl).minimalPeriod_dvd
    ((key _).1 (Function.isPeriodicPt_minimalPeriod _ _))

variable [Fintype K] [DecidableEq K]

theorem card_fixed_affMap (ha : a ≠ 1) : #{x | affMap a b x = x} = 1 := by
  rw [card_eq_one]
  exact ⟨affFix a b, by ext x; simp [affMap_fixed_iff ha]⟩

theorem card_fixed_translation (hb : b ≠ 0) : #{x | affMap 1 b x = x} = 0 := by
  simp [affMap, hb]

theorem card_fixed_id : #{x | affMap (1 : K) 0 x = x} = Fintype.card K := by
  simp [affMap]

end Affine

/-! ## 3. The septic model `AGL(1,7)` -/

instance fact_prime_seven : Fact (Nat.Prime 7) := ⟨by norm_num⟩

/-- Computable multiplicative order on `ℤ/7` (agrees with `orderOf` on units). -/
def ord7 (a : ZMod 7) : ℕ :=
  if a = 1 then 1 else if a ^ 2 = 1 then 2 else if a ^ 3 = 1 then 3 else 6

theorem ord7_eq_orderOf (a : ZMod 7) (ha : a ≠ 0) : ord7 a = orderOf a := by
  fin_cases a
  · exact absurd rfl ha
  all_goals exact ((orderOf_eq_iff (by decide)).2 ⟨by decide, by decide⟩).symm

/-- The septic splitting type of the Frobenius `x ↦ a x + b` in `F₄₂ = AGL(1,7)`:
(number of fixed roots, length of the non-trivial cycles). `(7,1)` = split completely,
`(0,7)` = inert, `(1,d)` = one linear factor and `6/d` factors of degree `d`. -/
def septicType (x : ZMod 7 × ZMod 7) : ℕ × ℕ :=
  if x.1 = 1 then (if x.2 = 0 then (7, 1) else (0, 7)) else (1, ord7 x.1)

/-- The group `F₄₂ = AGL(1,7)` as the set of pairs `(a, b)` with `a ≠ 0` (42 elements). -/
def S7 : Finset (ZMod 7 × ZMod 7) := {x | x.1 ≠ 0}

theorem card_S7 : S7.card = 42 := by decide

/-- The septic type is the actual cycle data of the affine permutation of the 7 roots. -/
theorem septicType_faithful (x : ZMod 7 × ZMod 7) (hx : x ∈ S7) :
    #{y | affMap x.1 x.2 y = y} = (septicType x).1 ∧
    ∀ y, affMap x.1 x.2 y ≠ y →
      Function.minimalPeriod (affMap x.1 x.2) y = (septicType x).2 := by
  obtain ⟨a, b⟩ := x
  have ha0 : a ≠ 0 := by simpa [S7] using hx
  simp only [septicType]
  by_cases ha : a = 1
  · subst ha
    by_cases hb : b = 0
    · subst hb
      refine ⟨by simp [card_fixed_id], fun y hy => absurd (by simp [affMap]) hy⟩
    · simp only [if_true, hb, if_false]
      exact ⟨card_fixed_translation hb, fun y _ => minimalPeriod_translation 7 hb y⟩
  · simp only [ha, if_false]
    refine ⟨card_fixed_affMap ha, fun y hy => ?_⟩
    rw [minimalPeriod_affMap ha (fun h => hy ((affMap_fixed_iff ha y).2 h)),
      ord7_eq_orderOf a ha0]

/-! ## 4. The septic channels -/

/-- The conductor residue: the linear part `a`, i.e. the Frobenius in `ℚ(ζ₇)`, `p mod 7`. -/
def conductorRes (x : ZMod 7 × ZMod 7) : ZMod 7 := x.1

lemma lb_two_mul (x : ℝ) (hx : 0 < x) : Real.logb 2 (2 * x) = 1 + Real.logb 2 x := by
  rw [Real.logb_mul (by norm_num) hx.ne', Real.logb_self_eq_one (by norm_num)]

lemma lb_14 : Real.logb 2 (14 : ℝ) = 1 + Real.logb 2 7 := by
  rw [show (14 : ℝ) = 2 * 7 by norm_num, lb_two_mul _ (by norm_num)]

lemma lb_42 : Real.logb 2 (42 : ℝ) = 1 + Real.logb 2 3 + Real.logb 2 7 := by
  rw [show (42 : ℝ) = 2 * (3 * 7) by norm_num, lb_two_mul _ (by norm_num),
    Real.logb_mul (by norm_num) (by norm_num)]
  ring

lemma septicType_counts :
    (S7.image septicType).val.map (fun v => (#{x ∈ S7 | septicType x = v} : ℕ))
      = {1, 6, 7, 14, 14} := by decide

lemma conductor_counts :
    (S7.image conductorRes).val.map (fun v => (#{x ∈ S7 | conductorRes x = v} : ℕ))
      = {7, 7, 7, 7, 7, 7} := by decide

lemma joint_counts :
    (S7.image (fun x => (septicType x, conductorRes x))).val.map
      (fun v => (#{x ∈ S7 | (septicType x, conductorRes x) = v} : ℕ))
      = {1, 6, 7, 7, 7, 7, 7} := by decide

/-- Entropy of the septic splitting type: fibre sizes `{1, 6, 7, 14, 14}` out of 42. -/
theorem septic_type_entropy :
    uEnt S7 septicType = 4 / 21 + (6 / 7) * Real.logb 2 3 + (1 / 6) * Real.logb 2 7 := by
  rw [uEnt_eq_countSum S7 septicType _ septicType_counts, card_S7]
  simp [lb_42, lb_14, lb_6]
  ring

theorem conductor_entropy : uEnt S7 conductorRes = Real.logb 2 6 := by
  rw [uEnt_eq_countSum S7 conductorRes _ conductor_counts, card_S7]
  simp [lb_42, lb_6]
  ring

theorem joint_entropy :
    uEnt S7 (fun x => (septicType x, conductorRes x))
      = 6 / 7 + (6 / 7) * Real.logb 2 3 + (1 / 6) * Real.logb 2 7 := by
  rw [uEnt_eq_countSum S7 _ _ joint_counts, card_S7]
  simp [lb_42, lb_6]
  ring

/-- **Massive signal at the conductor**: `I(T ; p mod 7) = 1/3 + log₂ 3 ≈ 1.918` bits. -/
theorem septic_conductor_info :
    mutInfo S7 septicType conductorRes = 1 / 3 + Real.logb 2 3 := by
  rw [mutInfo_eq_add_sub_pair, septic_type_entropy, conductor_entropy, joint_entropy, lb_6]
  ring

/-- **THE-FRAMEWORK-EXTENDS**: the degree-7 conductor signal equals the degree-6 cyclic
type entropy `typeEntropy 6` of the catalog. -/
theorem septic_conductor_eq_sextic :
    mutInfo S7 septicType conductorRes = typeEntropy 6 := by
  rw [septic_conductor_info, typeEntropy_val_6]; ring

/-! ## 5. Every prime degree: the conductor channel is the cyclic type channel -/

section Transfer

variable [DecidableEq β]

lemma uEnt_congr_fiber_card {β' : Type*} [DecidableEq β'] (s : Finset α) (g : α → β)
    (g' : α → β') (h : ∀ x ∈ s, #{y ∈ s | g y = g x} = #{y ∈ s | g' y = g' x}) :
    uEnt s g = uEnt s g' := by
  unfold uEnt
  rw [Finset.sum_congr rfl fun x hx => by rw [h x hx]]

lemma uEnt_congr (s : Finset α) (g g' : α → β) (h : ∀ x ∈ s, g x = g' x) :
    uEnt s g = uEnt s g' := by
  refine uEnt_congr_fiber_card s g g' fun x hx => ?_
  congr 1
  exact Finset.filter_congr fun y hy => by rw [h x hx, h y hy]

/-- Entropy is invariant under relabelling the sample space injectively. -/
theorem uEnt_image_injOn {α' : Type*} [DecidableEq α'] (s : Finset α) (e : α → α')
    (he : Set.InjOn e s) (g : α' → β) : uEnt (s.image e) g = uEnt s (g ∘ e) := by
  unfold uEnt
  rw [card_image_of_injOn he, sum_image he]
  congr 2
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [Finset.filter_image, card_image_of_injOn (he.mono (coe_subset.2 (filter_subset _ _)))]
  rfl

/-- **Split invariance**: if `g` refines `g'` and `h` refines `h'` by splitting the same
fibres in the same way (on `P`), and they agree off `P`, the entropy gaps coincide. -/
theorem uEnt_sub_eq_of_split {β₂ β₃ β₄ : Type*} [DecidableEq β₂] [DecidableEq β₃]
    [DecidableEq β₄] (s : Finset α) (g : α → β) (g' : α → β₂) (h : α → β₃) (h' : α → β₄)
    (P : α → Prop) [DecidablePred P]
    (hout : ∀ x ∈ s, ¬ P x → #{y ∈ s | g y = g x} = #{y ∈ s | g' y = g' x} ∧
        #{y ∈ s | h y = h x} = #{y ∈ s | h' y = h' x})
    (hin : ∀ x ∈ s, P x → #{y ∈ s | g y = g x} = #{y ∈ s | h y = h x} ∧
        #{y ∈ s | g' y = g' x} = #{y ∈ s | h' y = h' x}) :
    uEnt s g - uEnt s g' = uEnt s h - uEnt s h' := by
  have key : (∑ x ∈ s, Real.logb 2 (#{y ∈ s | g y = g x} : ℝ))
      - ∑ x ∈ s, Real.logb 2 (#{y ∈ s | g' y = g' x} : ℝ)
      = (∑ x ∈ s, Real.logb 2 (#{y ∈ s | h y = h x} : ℝ))
      - ∑ x ∈ s, Real.logb 2 (#{y ∈ s | h' y = h' x} : ℝ) := by
    rw [← sum_sub_distrib, ← sum_sub_distrib]
    refine Finset.sum_congr rfl fun x hx => ?_
    by_cases hP : P x
    · rw [(hin x hx hP).1, (hin x hx hP).2]
    · rw [(hout x hx hP).1, (hout x hx hP).2, sub_self, sub_self]
  unfold uEnt
  linear_combination (-1 / (s.card : ℝ)) * key

end Transfer

section GeneralPrime

variable (q : ℕ) [hq : Fact q.Prime]

/-- `AGL(1,q)` as the set of pairs `(a, b)` with `a ≠ 0`. -/
def Sq : Finset (ZMod q × ZMod q) := {x | x.1 ≠ 0}

/-- The splitting type of `x ↦ a x + b` in `AGL(1,q)` (Galois group of `x^q - c`, generic `c`). -/
noncomputable def affType (x : ZMod q × ZMod q) : ℕ × ℕ :=
  if x.1 = 1 then (if x.2 = 0 then (q, 1) else (0, q)) else (1, orderOf x.1)

variable {q}

lemma affType_of_ne {y : ZMod q × ZMod q} (h : y.1 ≠ 1) : affType q y = (1, orderOf y.1) := by
  simp [affType, h]

lemma affType_fst_ne_one {y : ZMod q × ZMod q} (h : y.1 = 1) : (affType q y).1 ≠ 1 := by
  have := hq.out.one_lt
  unfold affType
  split_ifs <;> simp
  omega

/-- The general type label is the actual cycle data of the affine permutation. -/
theorem affType_faithful (x : ZMod q × ZMod q) (hx : x ∈ Sq q) :
    #{y | affMap x.1 x.2 y = y} = (affType q x).1 ∧
    ∀ y, affMap x.1 x.2 y ≠ y →
      Function.minimalPeriod (affMap x.1 x.2) y = (affType q x).2 := by
  obtain ⟨a, b⟩ := x
  simp only [affType]
  by_cases ha : a = 1
  · subst ha
    by_cases hb : b = 0
    · subst hb
      refine ⟨by simp [affMap], fun y hy => absurd (by simp [affMap]) hy⟩
    · simp only [if_true, hb, if_false]
      exact ⟨card_fixed_translation hb, fun y _ => minimalPeriod_translation q hb y⟩
  · simp only [ha, if_false]
    exact ⟨card_fixed_affMap ha, fun y hy =>
      minimalPeriod_affMap ha (fun h => hy ((affMap_fixed_iff ha y).2 h))⟩

/-- The conductor information equals the entropy of the order of the linear part. -/
theorem agl_conductor_info_eq_orderEntropy :
    mutInfo (Sq q) (affType q) Prod.fst = uEnt (Sq q) (fun x => orderOf x.1) := by
  have key := uEnt_sub_eq_of_split (Sq q) (affType q) (fun x => orderOf x.1)
    (fun x => (affType q x, x.1)) Prod.fst (fun x => x.1 = 1) ?_ ?_
  · rw [mutInfo_eq_add_sub_pair]; linarith
  · intro x _ hx
    replace hx : x.1 ≠ 1 := hx
    have hox : orderOf x.1 ≠ 1 := fun h => hx (orderOf_eq_one_iff.1 h)
    constructor
    · congr 1
      refine Finset.filter_congr fun y _ => ?_
      show affType q y = affType q x ↔ orderOf y.1 = orderOf x.1
      rw [affType_of_ne hx]
      by_cases hy : y.1 = 1
      · have h1 := affType_fst_ne_one (q := q) hy
        constructor
        · intro h; exact absurd (by rw [h]) h1
        · intro h; exact absurd (by rw [← h, hy, orderOf_one]) hox
      · rw [affType_of_ne hy]; simp
    · congr 1
      refine Finset.filter_congr fun y _ => ?_
      show (affType q y, y.1) = (affType q x, x.1) ↔ y.1 = x.1
      constructor
      · intro h; exact (Prod.mk.inj h).2
      · intro h
        have hy : y.1 ≠ 1 := by rw [h]; exact hx
        rw [affType_of_ne hy, affType_of_ne hx, h]
  · intro x _ hx
    replace hx : x.1 = 1 := hx
    constructor
    · congr 1
      refine Finset.filter_congr fun y _ => ?_
      show affType q y = affType q x ↔ (affType q y, y.1) = (affType q x, x.1)
      constructor
      · intro h
        refine Prod.ext h ?_
        show y.1 = x.1
        by_contra hy
        have hy1 : y.1 ≠ 1 := fun h' => hy (by rw [h', hx])
        have := affType_fst_ne_one (q := q) hx
        rw [← h, affType_of_ne hy1] at this
        exact this rfl
      · intro h; exact (Prod.mk.inj h).1
    · congr 1
      refine Finset.filter_congr fun y _ => ?_
      show orderOf y.1 = orderOf x.1 ↔ y.1 = x.1
      rw [hx, orderOf_one, orderOf_eq_one_iff]

/-- The order of the linear part of a uniform element of `AGL(1,q)` has entropy
`typeEntropy (q - 1)`. -/
theorem orderEntropy_eq_typeEntropy :
    uEnt (Sq q) (fun x => orderOf x.1) = typeEntropy (q - 1) := by
  have hS : Sq q = ({a | a ≠ 0} : Finset (ZMod q)) ×ˢ (univ : Finset (ZMod q)) := by
    ext x; simp [Sq]
  rw [hS, uEnt_prod_fst _ _ (fun a : ZMod q => orderOf a) univ_nonempty]
  obtain ⟨g, hg, hall⟩ := exists_generator_ordType q
  let e : ℕ → ZMod q := fun i => ((g ^ i : (ZMod q)ˣ) : ZMod q)
  have he : Set.InjOn e (range (q - 1)) := by
    intro i hi j hj hij
    have hi' : i < orderOf g := by rw [hg]; simpa using hi
    have hj' : j < orderOf g := by rw [hg]; simpa using hj
    exact pow_injOn_Iio_orderOf hi' hj' (Units.ext hij)
  have himg : ({a | a ≠ 0} : Finset (ZMod q)) = (range (q - 1)).image e := by
    ext a
    simp only [mem_filter, mem_univ, true_and, mem_image, mem_range]
    constructor
    · intro ha
      obtain ⟨i, hi, hu, -⟩ := hall (Units.mk0 a ha)
      exact ⟨i, hi, by simp only [e]; rw [← hu, Units.val_mk0]⟩
    · rintro ⟨i, -, rfl⟩
      exact Units.ne_zero _
  rw [himg, uEnt_image_injOn _ e he, typeEntropy]
  refine uEnt_congr _ _ _ fun i _ => ?_
  simp only [Function.comp, e]
  rw [orderOf_units, orderOf_pow_eq_ordType, hg]

/-- **THE-FRAMEWORK-EXTENDS, every prime degree.** -/
theorem agl_conductor_info :
    mutInfo (Sq q) (affType q) Prod.fst = typeEntropy (q - 1) := by
  rw [agl_conductor_info_eq_orderEntropy, orderEntropy_eq_typeEntropy]

end GeneralPrime

/-! ## 6. Consistency, flatness and the abelian obstruction -/

theorem septicType_eq_affType (x : ZMod 7 × ZMod 7) (hx : x ∈ S7) :
    septicType x = affType 7 x := by
  have hx0 : x.1 ≠ 0 := by simpa [S7] using hx
  unfold septicType affType
  split_ifs <;> first | rfl | rw [ord7_eq_orderOf _ hx0]

/-- Cross-check: the computable septic model agrees with the general `AGL(1,7)` model. -/
theorem septic_general_consistency :
    mutInfo S7 septicType conductorRes = mutInfo (Sq 7) (affType 7) Prod.fst ∧
    mutInfo (Sq 7) (affType 7) Prod.fst = 1 / 3 + Real.logb 2 3 := by
  have hS : S7 = Sq 7 := rfl
  have h : mutInfo S7 septicType conductorRes = mutInfo (Sq 7) (affType 7) Prod.fst := by
    unfold mutInfo condEnt
    rw [uEnt_congr S7 septicType (affType 7) septicType_eq_affType, ← hS]
    refine congrArg _ (Finset.sum_congr rfl fun c _ => ?_)
    rw [uEnt_congr _ septicType (affType 7)
      (fun x hx => septicType_eq_affType x (mem_filter.1 hx).1)]
    rfl
  exact ⟨h, h ▸ septic_conductor_info⟩

/-- The residual type information not explained by `p mod 7`. -/
theorem septic_residual :
    condEnt S7 septicType conductorRes
      = (1 / 6) * Real.logb 2 7 - 1 / 7 - (1 / 7) * Real.logb 2 3 := by
  have h := septic_conductor_info
  rw [mutInfo, septic_type_entropy] at h
  linarith

/-- The conductor signal exceeds `11/6` bits and is bounded by the full type entropy. -/
theorem septic_signal_dominates :
    11 / 6 < mutInfo S7 septicType conductorRes ∧
    mutInfo S7 septicType conductorRes ≤ uEnt S7 septicType := by
  refine ⟨by rw [septic_conductor_info]; linarith [lb_three_gt], ?_⟩
  have : 0 ≤ condEnt S7 septicType conductorRes := by
    unfold condEnt
    exact Finset.sum_nonneg fun c _ => mul_nonneg (by positivity) (uEnt_nonneg _ _)
  rw [mutInfo]; linarith

/-- **Flat at coprime moduli** (general prime degree, product/linear-disjointness model). -/
theorem agl_coprime_flat (q : ℕ) [Fact q.Prime] {C : Type*} [DecidableEq C] (t : Finset C) :
    mutInfo (Sq q ×ˢ t) (fun x => affType q x.1) (fun x => x.2) = 0 :=
  mutInfo_prod_indep (Sq q) t (affType q) id

/-- **Flat at coprime moduli** for `x⁷ - 3`: in the model `F₄₂ × (ℤ/m)ˣ` the residue
`p mod m` carries no information about the septic type. -/
theorem septic_coprime_flat (m : ℕ) [NeZero m] :
    mutInfo (S7 ×ˢ (univ : Finset (ZMod m)ˣ)) (fun x => septicType x.1) (fun x => x.2) = 0 :=
  mutInfo_prod_indep S7 univ septicType id

section Abelian

variable {K : Type*} [Field K]

/-- Translation `x ↦ x + c` as a permutation. -/
def transl (c : K) : Equiv.Perm K := Equiv.addRight c

/-- Scaling `x ↦ a x` as a permutation. -/
def scal (a : K) (ha : a ≠ 0) : Equiv.Perm K := Equiv.mulLeft₀ a ha

lemma scal_transl_conj (a c : K) (ha : a ≠ 0) :
    scal a ha * transl c * (scal a ha)⁻¹ = transl (a * c) := by
  ext x
  simp [scal, transl, Equiv.Perm.mul_apply, Equiv.mulLeft₀]
  field_simp

lemma transl_eq_commutator (a c : K) (ha : a ≠ 0) :
    transl ((a - 1) * c) = ⁅scal a ha, transl c⁆ := by
  rw [commutatorElement_def, scal_transl_conj]
  ext x
  simp [transl, Equiv.Perm.mul_apply]
  ring

/-- **Abelian obstruction.** Any homomorphism to an abelian group from a group of affine
permutations containing a non-trivial scaling and all translations kills every translation. -/
theorem abelian_character_kills_translations {A : Type*} [CommGroup A]
    (H : Subgroup (Equiv.Perm K)) (a : K) (ha : a ≠ 0) (ha1 : a ≠ 1)
    (hs : scal a ha ∈ H) (ht : ∀ c, transl c ∈ H) (χ : H →* A) (b : K) :
    χ ⟨transl b, ht b⟩ = 1 := by
  have hsub : a - 1 ≠ 0 := sub_ne_zero.2 ha1
  have hb : transl b = ⁅scal a ha, transl (b / (a - 1))⁆ := by
    rw [← transl_eq_commutator]; congr 1; field_simp
  have : (⟨transl b, ht b⟩ : H) = ⁅(⟨scal a ha, hs⟩ : H), ⟨transl (b / (a - 1)), ht _⟩⁆ :=
    Subtype.ext (by simpa using hb)
  rw [this, map_commutatorElement, commutatorElement_eq_one_iff_mul_comm]
  exact mul_comm _ _

end Abelian

/-! ## 7. The universal residual law -/

section Residual

variable {q : ℕ} [hq : Fact q.Prime]

lemma card_Sq_fst_fiber (c : ZMod q) (hc : c ≠ 0) : #{y ∈ Sq q | y.1 = c} = q := by
  have : {y ∈ Sq q | y.1 = c} = (univ : Finset (ZMod q)).image (fun b => (c, b)) := by
    ext y; simp [Sq]; constructor
    · rintro ⟨-, h⟩; exact ⟨y.2, by rw [← h]⟩
    · rintro ⟨b, rfl⟩; exact ⟨hc, rfl⟩
  rw [this, card_image_of_injective _ (fun b b' h => (Prod.mk.inj h).2), card_univ, ZMod.card]

lemma fiberJ_of_ne {x : ZMod q × ZMod q} (hx : x.1 ≠ 1) :
    {y ∈ Sq q | (affType q y, y.1) = (affType q x, x.1)} = {y ∈ Sq q | y.1 = x.1} := by
  refine Finset.filter_congr fun y _ => ?_
  constructor
  · intro h; exact (Prod.mk.inj h).2
  · intro h
    have hy : y.1 ≠ 1 := by rw [h]; exact hx
    rw [affType_of_ne hy, affType_of_ne hx, h]

lemma fiberJ_one (b : ZMod q) :
    {y ∈ Sq q | (affType q y, y.1) = (affType q (1, b), (1 : ZMod q))}
      = {y ∈ Sq q | y.1 = 1 ∧ (y.2 = 0 ↔ b = 0)} := by
  have hq0 : q ≠ 0 := hq.out.ne_zero
  refine Finset.filter_congr fun y _ => ?_
  constructor
  · intro h
    have h1 : y.1 = 1 := (Prod.mk.inj h).2
    have h2 := (Prod.mk.inj h).1
    refine ⟨h1, ?_⟩
    unfold affType at h2
    simp only [h1, if_true] at h2
    split_ifs at h2 with hy hb hb <;> simp_all
  · rintro ⟨h1, h2⟩
    refine Prod.ext ?_ h1
    unfold affType
    simp only [h1, if_true]
    by_cases hb : b = 0 <;> simp_all

lemma card_Sq : (Sq q).card = q * (q - 1) := by
  have hS : Sq q = ({a | a ≠ 0} : Finset (ZMod q)) ×ˢ (univ : Finset (ZMod q)) := by
    ext x; simp [Sq]
  rw [hS, card_product, filter_ne', card_erase_of_mem (mem_univ _), card_univ, ZMod.card]
  ring

/-- Fibre-size log-sum of the joint (type, conductor) variable. -/
theorem sum_log_fiberJ :
    ∑ x ∈ Sq q, Real.logb 2 (#{y ∈ Sq q | (affType q y, y.1) = (affType q x, x.1)} : ℝ)
      = ((q : ℝ) * ((q : ℝ) - 2)) * Real.logb 2 q + ((q : ℝ) - 1) * Real.logb 2 ((q : ℝ) - 1) := by
  have h2 := hq.out.two_le
  have hS : Sq q = ({a | a ≠ 0} : Finset (ZMod q)) ×ˢ (univ : Finset (ZMod q)) := by
    ext x; simp [Sq]
  have h1mem : (1 : ZMod q) ∈ ({a | a ≠ 0} : Finset (ZMod q)) := by simp
  rw [hS, sum_product, ← add_sum_erase _ _ h1mem, ← hS]
  have hrest : ∀ a ∈ ({a | a ≠ 0} : Finset (ZMod q)).erase 1,
      ∑ b, Real.logb 2 (#{y ∈ Sq q | (affType q y, y.1) = (affType q (a, b), (a, b).1)} : ℝ)
        = q * Real.logb 2 q := by
    intro a ha
    simp only [mem_erase, mem_filter, mem_univ, true_and] at ha
    rw [Finset.sum_congr rfl fun b _ => by
      rw [fiberJ_of_ne (x := (a, b)) ha.1, card_Sq_fst_fiber _ ha.2]]
    simp [card_univ, ZMod.card]
  have hone : ∑ b, Real.logb 2 (#{y ∈ Sq q | (affType q y, y.1) = (affType q (1, b), (1, b).1)} : ℝ)
      = ((q : ℝ) - 1) * Real.logb 2 ((q : ℝ) - 1) := by
    rw [← add_sum_erase _ _ (mem_univ (0 : ZMod q))]
    have hz : #{y ∈ Sq q | (affType q y, y.1) = (affType q (1, 0), ((1, 0) : ZMod q × ZMod q).1)}
        = 1 := by
      rw [fiberJ_one, card_eq_one]
      refine ⟨(1, 0), ?_⟩
      ext y; simp [Sq, Prod.ext_iff]
      intro h1 _; rw [h1]; exact one_ne_zero
    have hnz : ∀ b ∈ (univ : Finset (ZMod q)).erase 0,
        #{y ∈ Sq q | (affType q y, y.1) = (affType q (1, b), ((1, b) : ZMod q × ZMod q).1)}
          = q - 1 := by
      intro b hb
      have hb0 : b ≠ 0 := (mem_erase.1 hb).1
      rw [fiberJ_one]
      have : {y ∈ Sq q | y.1 = 1 ∧ (y.2 = 0 ↔ b = 0)}
          = ((univ : Finset (ZMod q)).erase 0).image (fun c => ((1 : ZMod q), c)) := by
        ext y; simp [Sq, hb0]; constructor
        · rintro ⟨-, h1, h2⟩; exact ⟨y.2, h2, by rw [← h1]⟩
        · rintro ⟨c, hc, rfl⟩; exact ⟨one_ne_zero, rfl, hc⟩
      rw [this, card_image_of_injective _ (fun b b' h => (Prod.mk.inj h).2),
        card_erase_of_mem (mem_univ _), card_univ, ZMod.card]
    rw [hz, Finset.sum_congr rfl fun b hb => by rw [hnz b hb], sum_const,
      card_erase_of_mem (mem_univ _), card_univ, ZMod.card, nsmul_eq_mul]
    push_cast [Nat.cast_sub (by omega : 1 ≤ q)]
    simp
  rw [hone, Finset.sum_congr rfl hrest, sum_const, card_erase_of_mem h1mem, filter_ne',
    card_erase_of_mem (mem_univ _), card_univ, ZMod.card, nsmul_eq_mul]
  push_cast [Nat.cast_sub (by omega : 1 ≤ q), Nat.cast_sub (by omega : 1 ≤ q - 1)]
  ring

/-- **The universal residual law.** -/
theorem agl_residual :
    condEnt (Sq q) (affType q) Prod.fst
      = ((q : ℝ) * Real.logb 2 q - ((q : ℝ) - 1) * Real.logb 2 ((q : ℝ) - 1))
          / ((q : ℝ) * ((q : ℝ) - 1)) := by
  have h2 := hq.out.two_le
  have hq1 : (1 : ℝ) < q := by exact_mod_cast h2
  have hNe : (Sq q).Nonempty := ⟨(1, 0), by simp [Sq]⟩
  have hcard : ((Sq q).card : ℝ) = (q : ℝ) * ((q : ℝ) - 1) := by
    rw [card_Sq]; push_cast [Nat.cast_sub (by omega : 1 ≤ q)]; ring
  rw [condEnt_eq_uEnt_pair_sub,
    uEnt_const_fiber (Sq q) Prod.fst q (fun x hx => card_Sq_fst_fiber _ (by simpa [Sq] using hx))
      hNe]
  unfold uEnt
  rw [sum_log_fiberJ, hcard]
  have : (q : ℝ) - 1 ≠ 0 := by linarith
  have : (q : ℝ) ≠ 0 := by linarith
  field_simp
  ring

/-- Type entropy decomposes as (cyclic `C_{q-1}` type entropy) + (residual). -/
theorem agl_type_entropy :
    uEnt (Sq q) (affType q)
      = typeEntropy (q - 1)
        + ((q : ℝ) * Real.logb 2 q - ((q : ℝ) - 1) * Real.logb 2 ((q : ℝ) - 1))
          / ((q : ℝ) * ((q : ℝ) - 1)) := by
  rw [← agl_residual, ← agl_conductor_info, mutInfo]; ring

/-- The residual is at most `log₂ q / (q - 1)` bits. -/
theorem agl_residual_le :
    condEnt (Sq q) (affType q) Prod.fst ≤ Real.logb 2 q / ((q : ℝ) - 1) := by
  have h2 := hq.out.two_le
  have hq1 : (1 : ℝ) < q := by exact_mod_cast h2
  have hq0 : (0 : ℝ) < q := by linarith
  have hlog : 0 ≤ Real.logb 2 ((q : ℝ) - 1) :=
    Real.logb_nonneg (by norm_num) (by linarith [show (2 : ℝ) ≤ q by exact_mod_cast h2])
  rw [agl_residual, div_le_div_iff₀ (by nlinarith) (by linarith)]
  have : 0 ≤ ((q : ℝ) - 1) * Real.logb 2 ((q : ℝ) - 1) := mul_nonneg (by linarith) hlog
  nlinarith

end Residual

/-! ## 8. Information completeness -/

section Completeness

/-- In `C_{2m}`, the splitting type divides `m` iff the exponent is even. -/
lemma ordType_dvd_half_iff {m : ℕ} (hm : 0 < m) (a : ℕ) : ordType (2 * m) a ∣ m ↔ 2 ∣ a := by
  haveI : NeZero (2 * m) := ⟨by omega⟩
  set g : Multiplicative (ZMod (2 * m)) := Multiplicative.ofAdd 1
  have hg : orderOf g = 2 * m := by
    simp [g, orderOf_ofAdd_eq_addOrderOf, ZMod.addOrderOf_one]
  rw [← hg, ← orderOf_pow_eq_ordType, orderOf_dvd_iff_pow_eq_one, ← pow_mul,
    ← orderOf_dvd_iff_pow_eq_one, hg]
  exact Nat.mul_dvd_mul_iff_right hm

lemma card_parity_fiber {m : ℕ} (b : ℕ) :
    #{x ∈ range (2 * m) | decide (2 ∣ x) = decide (2 ∣ b)} = m := by
  by_cases hb : 2 ∣ b
  · have : {x ∈ range (2 * m) | decide (2 ∣ x) = decide (2 ∣ b)}
        = (range m).image (fun i => 2 * i) := by
      ext x; simp only [mem_filter, mem_range, mem_image, hb, decide_true, decide_eq_true_eq]
      constructor
      · rintro ⟨hx, ⟨i, rfl⟩⟩; exact ⟨i, by omega, rfl⟩
      · rintro ⟨i, hi, rfl⟩; exact ⟨by omega, dvd_mul_right 2 i⟩
    rw [this, card_image_of_injective _ (fun i j h => by simpa using h), card_range]
  · have : {x ∈ range (2 * m) | decide (2 ∣ x) = decide (2 ∣ b)}
        = (range m).image (fun i => 2 * i + 1) := by
      ext x; simp only [mem_filter, mem_range, mem_image, hb, decide_false,
        decide_eq_false_iff_not]
      constructor
      · rintro ⟨hx, hx2⟩; exact ⟨x / 2, by omega, by omega⟩
      · rintro ⟨i, hi, rfl⟩; exact ⟨by omega, by omega⟩
    rw [this, card_image_of_injective _ (fun i j h => by simpa using h), card_range]

/-- The cyclic type channel of an even-order cyclic group carries at least one bit. -/
theorem one_le_typeEntropy_even {m : ℕ} (hm : 0 < m) : 1 ≤ typeEntropy (2 * m) := by
  have h1 := uEnt_comp_le (range (2 * m)) (ordType (2 * m)) (fun d => decide (d ∣ m))
  have h2 : uEnt (range (2 * m)) ((fun d => decide (d ∣ m)) ∘ ordType (2 * m))
      = uEnt (range (2 * m)) (fun a => decide (2 ∣ a)) :=
    uEnt_congr _ _ _ fun a _ => by simp [ordType_dvd_half_iff hm]
  have h3 : uEnt (range (2 * m)) (fun a => decide (2 ∣ a)) = 1 := by
    rw [uEnt_const_fiber _ _ m (fun a _ => card_parity_fiber a) ⟨0, by simp; omega⟩,
      card_range]
    push_cast
    rw [lb_two_mul _ (by exact_mod_cast hm)]; ring
  rw [typeEntropy]; linarith

variable {q : ℕ} [hq : Fact q.Prime]

/-- For odd prime degree the conductor signal is at least one bit. -/
theorem one_le_agl_conductor_info (hq2 : q ≠ 2) :
    1 ≤ mutInfo (Sq q) (affType q) Prod.fst := by
  have hodd := hq.out.eq_two_or_odd'.resolve_left hq2
  obtain ⟨k, hk⟩ := hodd
  have h2 := hq.out.two_le
  have hk0 : 0 < k := by omega
  rw [agl_conductor_info, show q - 1 = 2 * k by omega]
  exact one_le_typeEntropy_even hk0

/-- **Information completeness.** For odd prime degree `q`, the conductor residue
`p mod q` explains at least a `1 - log₂ q / (q - 1)` fraction of the splitting-type
entropy; the fraction tends to `1`. -/
theorem agl_information_completeness (hq2 : q ≠ 2) :
    1 - Real.logb 2 q / ((q : ℝ) - 1)
      ≤ mutInfo (Sq q) (affType q) Prod.fst / uEnt (Sq q) (affType q) := by
  have hI := one_le_agl_conductor_info hq2
  have hR := agl_residual_le (q := q)
  have hR0 : 0 ≤ condEnt (Sq q) (affType q) Prod.fst := by
    unfold condEnt
    exact Finset.sum_nonneg fun c _ => mul_nonneg (by positivity) (uEnt_nonneg _ _)
  have hH : uEnt (Sq q) (affType q)
      = mutInfo (Sq q) (affType q) Prod.fst + condEnt (Sq q) (affType q) Prod.fst := by
    rw [mutInfo]; ring
  rw [hH, le_div_iff₀ (by linarith)]
  set I := mutInfo (Sq q) (affType q) Prod.fst
  set R := condEnt (Sq q) (affType q) Prod.fst
  set L := Real.logb 2 q / ((q : ℝ) - 1)
  nlinarith

end Completeness

end SepticFrontier