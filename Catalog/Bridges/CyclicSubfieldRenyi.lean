/-
# The whole Rényi family is conductor-independent

The previous cycles proved that the *Shannon* entropy of a subfield splitting-type
channel does not see the conductor it is cut out of.  Direction 3 of
`FUTURE_DIRECTIONS.md` conjectured that this is not a property of the Shannon
functional at all, but of the push-forward distribution: a uniform cover leaves
the whole probability vector unchanged, so *every* functional of it — in
particular every Rényi order — is invariant.

This file proves that, and then reads off the conductor-13 cubic channel at all
Rényi orders.

* `pushProb`, `pushProb_of_uniform_cover`, `image_eq_of_uniform_cover` — the
  distributional statement: a uniform cover preserves the support and every
  probability.
* `sum_pushProb_functional_of_uniform_cover` — the master invariance: for **any**
  `F : ℝ → ℝ`, the sum `∑_v F(p_v)` over the support is unchanged.
* `uRenyi`, `uRenyi_of_uniform_cover` — hence the Rényi entropy of every order
  `a` is invariant under uniform covers.
* `uRenyi_transfer_of_modPeriodic`, `subfield_typeRenyi_of_dvd` — the arithmetic
  instance: the Rényi entropy of a subfield channel is conductor-independent.
* `conductor13_renyi_formula`, `conductor13_renyi_zero`,
  `conductor13_collision_entropy`, `cubic_renyi_pinned_all_conductors` — the
  cyclic cubic channel of conductor 13 at every Rényi order:
  `H_a = (1-a)⁻¹ log₂((1/3)^a + (2/3)^a)`, with `H_0 = 1` bit (two types) and
  collision entropy `H_2 = log₂(9/5)`, and the same numbers at every prime
  conductor `f` with `3 ∣ f - 1`.
* `conductor13_collision_lt_shannon` — the strict Rényi ordering at conductor 13:
  `H_2 = log₂(9/5) < log₂ 3 - 2/3 = H_1`, proved from the integer inequality
  `108 < 125`.
-/

import Bridges.CyclicSubfieldUniformCover

namespace CyclicSubfield

open Finset Real CyclicTypeChannel

variable {α α' β γ : Type*} [DecidableEq β]

/-! ## 1. The push-forward distribution -/

/-- The push-forward probability of the value `v`: the fraction of `s` on which
the read-out `g` takes the value `v`. -/
noncomputable def pushProb (s : Finset α) (g : α → β) (v : β) : ℝ :=
  (#{x ∈ s | g x = v} : ℝ) / s.card

/-- A uniform cover preserves the support of the push-forward distribution. -/
theorem image_eq_of_uniform_cover [DecidableEq α'] {s : Finset α} {t : Finset α'}
    {φ : α → α'} {r : ℕ} (hr : 0 < r)
    (hmaps : ∀ x ∈ s, φ x ∈ t) (hfib : ∀ y ∈ t, #{x ∈ s | φ x = y} = r)
    (h' : α' → β) :
    s.image (h' ∘ φ) = t.image h' := by
  classical
  apply Finset.Subset.antisymm
  · intro v hv
    obtain ⟨x, hx, rfl⟩ := mem_image.1 hv
    exact mem_image.2 ⟨φ x, hmaps x hx, rfl⟩
  · intro v hv
    obtain ⟨y, hy, rfl⟩ := mem_image.1 hv
    obtain ⟨x, hx, hxy⟩ := surj_of_uniform_cover hr hfib hy
    exact mem_image.2 ⟨x, hx, by simp [Function.comp, hxy]⟩

/-- **A uniform cover preserves every push-forward probability.**  This is the
distributional core of all the invariance statements: the fibre counts upstairs
are `r` times those downstairs, and so is the total. -/
theorem pushProb_of_uniform_cover [DecidableEq α'] {s : Finset α} {t : Finset α'}
    {φ : α → α'} {r : ℕ} (hr : 0 < r)
    (hmaps : ∀ x ∈ s, φ x ∈ t) (hfib : ∀ y ∈ t, #{x ∈ s | φ x = y} = r)
    (h' : α' → β) (v : β) :
    pushProb s (h' ∘ φ) v = pushProb t h' v := by
  classical
  have hrR : (0 : ℝ) < (r : ℝ) := by exact_mod_cast hr
  have hfibv := card_fiber_of_uniform_cover hmaps hfib h' v
  have hcards := card_of_uniform_cover hmaps hfib
  have hset : {x ∈ s | (h' ∘ φ) x = v} = {x ∈ s | h' (φ x) = v} := rfl
  unfold pushProb
  rw [hset, hfibv, hcards]
  push_cast
  rw [mul_div_mul_left _ _ (ne_of_gt hrR)]

/-- **Master invariance.**  Every functional of the push-forward distribution is
invariant under uniform covers — no property of the Shannon logarithm is used. -/
theorem sum_pushProb_functional_of_uniform_cover [DecidableEq α'] {s : Finset α}
    {t : Finset α'} {φ : α → α'} {r : ℕ} (hr : 0 < r)
    (hmaps : ∀ x ∈ s, φ x ∈ t) (hfib : ∀ y ∈ t, #{x ∈ s | φ x = y} = r)
    (h' : α' → β) (F : ℝ → ℝ) :
    ∑ v ∈ s.image (h' ∘ φ), F (pushProb s (h' ∘ φ) v)
      = ∑ v ∈ t.image h', F (pushProb t h' v) := by
  rw [image_eq_of_uniform_cover hr hmaps hfib h']
  exact Finset.sum_congr rfl fun v _ => by
    rw [pushProb_of_uniform_cover hr hmaps hfib h' v]

/-! ## 2. Rényi entropy of the counting channel -/

/-- The Rényi entropy of order `a` of the push-forward of the uniform
distribution on `s` along `g`:
`H_a = (1-a)⁻¹ · log₂ (∑_v p_v^a)`.
For `a = 0` this is the Hartley entropy `log₂ |support|`, and for `a = 2` the
collision entropy. -/
noncomputable def uRenyi (a : ℝ) (s : Finset α) (g : α → β) : ℝ :=
  (1 - a)⁻¹ * Real.logb 2 (∑ v ∈ s.image g, (pushProb s g v) ^ a)

/-- **Rényi entropy of every order is invariant under uniform covers.** -/
theorem uRenyi_of_uniform_cover [DecidableEq α'] {s : Finset α} {t : Finset α'}
    {φ : α → α'} {r : ℕ} (hr : 0 < r)
    (hmaps : ∀ x ∈ s, φ x ∈ t) (hfib : ∀ y ∈ t, #{x ∈ s | φ x = y} = r)
    (h' : α' → β) (a : ℝ) :
    uRenyi a s (h' ∘ φ) = uRenyi a t h' := by
  unfold uRenyi
  rw [sum_pushProb_functional_of_uniform_cover hr hmaps hfib h' (fun p => p ^ a)]

/-- At order `0` the Rényi entropy is the Hartley entropy `log₂ |support|`. -/
theorem uRenyi_zero (s : Finset α) (g : α → β) :
    uRenyi 0 s g = Real.logb 2 ((s.image g).card : ℝ) := by
  unfold uRenyi
  simp

/-! ## 3. The arithmetic instance: conductor-independence -/

/-- **The Rényi transfer law.**  For an `m`-periodic read-out, the Rényi entropy
of any order computed over `range (m * k)` equals the one computed over
`range m`: the conductor is invisible at every Rényi order, exactly as it is for
the Shannon entropy. -/
theorem uRenyi_transfer_of_modPeriodic {m k : ℕ} (hm : 0 < m) (hk : 0 < k) {h : ℕ → β}
    (hper : ModPeriodic m h) (a : ℝ) :
    uRenyi a (range (m * k)) h = uRenyi a (range m) h := by
  classical
  have hk' : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hprob : ∀ v : β, pushProb (range (m * k)) h v = pushProb (range m) h v := by
    intro v
    have hcard := card_fiber_of_modPeriodic (k := k) hm hper v
    unfold pushProb
    rw [card_range, card_range, hcard]
    push_cast
    rw [mul_comm (m : ℝ) (k : ℝ), mul_div_mul_left _ _ (ne_of_gt hk')]
  unfold uRenyi
  rw [image_of_modPeriodic hm hk hper]
  refine congrArg _ (congrArg _ (Finset.sum_congr rfl fun v _ => ?_))
  rw [hprob v]

/-- The intrinsic Rényi entropy of the degree-`m` cyclic type channel. -/
noncomputable def typeRenyi (a : ℝ) (m : ℕ) : ℝ := uRenyi a (range m) (ordType m)

/-- **Conductor-independence of the subfield channel at every Rényi order.** -/
theorem subfield_typeRenyi_of_dvd {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (hmn : m ∣ n)
    (a : ℝ) : uRenyi a (range n) (ordType m) = typeRenyi a m := by
  obtain ⟨k, rfl⟩ := hmn
  have hk : 0 < k := by
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · simp at hn
    · exact hk
  exact uRenyi_transfer_of_modPeriodic hm hk (modPeriodic_ordType m) a

/-! ## 4. The cyclic cubic channel of conductor 13 at every order -/

/-- The two push-forward probabilities of the conductor-13 cubic channel are
`1/3` (split) and `2/3` (inert). -/
theorem conductor13_pushProb :
    pushProb (range 12) (ordType 3) 1 = 1 / 3 ∧
      pushProb (range 12) (ordType 3) 3 = 2 / 3 := by
  have h := CyclicCubic13.conductor13_type_counts
  constructor <;> · unfold pushProb; rw [card_range]; norm_num [h.1, h.2]

/-- **The conductor-13 cubic channel at every Rényi order.** -/
theorem conductor13_renyi_formula (a : ℝ) :
    uRenyi a (range 12) (ordType 3)
      = (1 - a)⁻¹ * Real.logb 2 ((1 / 3 : ℝ) ^ a + (2 / 3 : ℝ) ^ a) := by
  have himg : (range 12).image (ordType 3) = {1, 3} :=
    CyclicCubic13.conductor13_two_types
  have hp := conductor13_pushProb
  unfold uRenyi
  rw [himg, Finset.sum_pair (by norm_num), hp.1, hp.2]

/-- Order `0`: the Hartley entropy is exactly one bit — there are two types. -/
theorem conductor13_renyi_zero : uRenyi 0 (range 12) (ordType 3) = 1 := by
  rw [conductor13_renyi_formula 0]
  norm_num

/-- Order `2`: the collision entropy of the conductor-13 cubic channel is
`log₂ (9/5)`. -/
theorem conductor13_collision_entropy :
    uRenyi 2 (range 12) (ordType 3) = Real.logb 2 (9 / 5) := by
  rw [conductor13_renyi_formula 2]
  have h1 : ((1 : ℝ) / 3) ^ (2 : ℝ) = 1 / 9 := by
    rw [show (2 : ℝ) = ((2 : ℕ) : ℝ) by norm_num, Real.rpow_natCast]
    norm_num
  have h2 : ((2 : ℝ) / 3) ^ (2 : ℝ) = 4 / 9 := by
    rw [show (2 : ℝ) = ((2 : ℕ) : ℝ) by norm_num, Real.rpow_natCast]
    norm_num
  rw [h1, h2]
  have hsum : (1 : ℝ) / 9 + 4 / 9 = 5 / 9 := by norm_num
  rw [hsum]
  have hlogb : Real.logb 2 (5 / 9) = -Real.logb 2 (9 / 5) := by
    rw [← Real.logb_inv]
    norm_num
  rw [hlogb]
  norm_num

/-- **Rényi pinning across conductors.**  For every prime conductor `f` with
`3 ∣ f - 1`, the cyclic cubic subfield channel has the same Rényi entropy of
every order as the intrinsic degree-3 channel. -/
theorem cubic_renyi_pinned_all_conductors {f : ℕ} (hf : f.Prime) (h3 : 3 ∣ f - 1)
    (a : ℝ) : uRenyi a (range (f - 1)) (ordType 3) = typeRenyi a 3 := by
  have hpos : 0 < f - 1 := by
    have := hf.two_le
    rcases Nat.eq_zero_or_pos (f - 1) with h | h
    · exfalso; omega
    · exact h
  exact subfield_typeRenyi_of_dvd (by norm_num) hpos h3 a

/-! ## 5. The strict Rényi ordering at conductor 13 -/

/-- `log₂(5/3) > 2/3`, equivalently `125 > 108`: the arithmetic fact behind the
strict separation of the collision and Shannon entropies. -/
theorem logb_five_thirds_gt : (2 : ℝ) / 3 < Real.logb 2 (5 / 3) := by
  have hcube : Real.logb 2 ((5 / 3 : ℝ) ^ (3 : ℕ)) = 3 * Real.logb 2 (5 / 3) := by
    rw [Real.logb_pow]
    push_cast
    ring
  have hval : ((5 : ℝ) / 3) ^ (3 : ℕ) = 125 / 27 := by norm_num
  have hlt : Real.logb 2 4 < Real.logb 2 (125 / 27) := by
    apply Real.logb_lt_logb (by norm_num) (by norm_num)
    norm_num
  have h4 : Real.logb 2 (4 : ℝ) = 2 := by
    rw [show (4 : ℝ) = (2 : ℝ) ^ (2 : ℕ) by norm_num, Real.logb_pow,
      Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
    norm_num
  rw [hval] at hcube
  linarith [hcube, hlt, h4]

/-- **The collision entropy is strictly below the Shannon entropy at conductor
13**: `H_2 = log₂(9/5) < log₂ 3 - 2/3 = H_1`, an instance of the Rényi ordering
made effective by an integer inequality. -/
theorem conductor13_collision_lt_shannon :
    uRenyi 2 (range 12) (ordType 3) < uEnt (range 12) (ordType 3) := by
  rw [conductor13_collision_entropy, CyclicCubic13.conductor13_entropy]
  have hsplit : Real.logb 2 (9 / 5 : ℝ)
      = 2 * Real.logb 2 3 - Real.logb 2 5 := by
    rw [Real.logb_div (by norm_num) (by norm_num)]
    rw [show (9 : ℝ) = (3 : ℝ) ^ (2 : ℕ) by norm_num, Real.logb_pow]
    push_cast
    ring
  have hgap : Real.logb 2 (5 / 3 : ℝ) = Real.logb 2 5 - Real.logb 2 3 :=
    Real.logb_div (by norm_num) (by norm_num)
  have := logb_five_thirds_gt
  rw [hgap] at this
  rw [hsplit]
  linarith

end CyclicSubfield