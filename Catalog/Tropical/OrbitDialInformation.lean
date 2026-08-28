import Mathlib
import Tropical.OrbitDialCapLaw
import Tropical.OrbitDialInvariants

/-!
# Zero information, positive speedup: the ORBIT dial is a constant shave

This file supplies the *information null* half of the ORBIT-DIAL-CAP-TEST
(FACT round-74 #2, exp 564) and joins it to the cap law of `Tropical.OrbitDialCapLaw`
and the orbit invariants of `Tropical.OrbitDialInvariants`.

We use elementary finite-alphabet mutual information

`I(X;Y) = ∑_{x,y} p(x,y) log ( p(x,y) / (p(x) p(y)) )`.

## Main results

* `OrbitDialCap.Info.mutualInfo_of_constant` — a dial whose output is the same symbol
  for every target has **exactly zero** mutual information with the target.  This is the
  measured `paired z = 0.0 EXACTLY` against the universal fixed dial.
* `OrbitDialCap.Info.perfectPair_mutualInfo` — for contrast, a one-bit residue dial
  (`Y = X` on two equiprobable classes) has mutual information `log 2`, i.e. exactly
  `1` bit, matching the ordinary residue-dial baselines `I(N mod m; p mod m) ≥ 1` bit.
* `OrbitDialCap.Info.orbit_dial_constant_shave` — the synthesis: the orbit dial has zero
  information yet a `2×` read, while every information-bearing exchangeable dial is
  capped at `4/3`.  So the `2.0000` read is a constant shave, not a barrier event.
-/

namespace OrbitDialCap
namespace Info

open Finset

variable {α β : Type*} [Fintype α] [Fintype β]

/-- Marginal law of the target. -/
noncomputable def marginalX (p : α → β → ℝ) (x : α) : ℝ := ∑ y, p x y

/-- Marginal law of the dial output. -/
noncomputable def marginalY (p : α → β → ℝ) (y : β) : ℝ := ∑ x, p x y

/-- Finite-alphabet mutual information of a joint law `p` on `α × β`. -/
noncomputable def mutualInfo (p : α → β → ℝ) : ℝ :=
  ∑ x, ∑ y, p x y * Real.log (p x y / (marginalX p x * marginalY p y))

/-- If the dial output is deterministic (always the symbol `y₀`), its marginal puts all
mass on `y₀`. -/
lemma marginalY_of_constant {p : α → β → ℝ} {y₀ : β}
    (htot : ∑ x, ∑ y, p x y = 1) (hconst : ∀ x, ∀ y, y ≠ y₀ → p x y = 0) :
    marginalY p y₀ = 1 := by
  have hx : ∀ x, marginalX p x = p x y₀ := by
    intro x
    refine Finset.sum_eq_single y₀ (fun y _ hy => hconst x y hy) (by simp)
  calc marginalY p y₀ = ∑ x, p x y₀ := rfl
    _ = ∑ x, marginalX p x := by simp [hx]
    _ = 1 := htot

/-- **The information null.**  A dial whose revealed symbol is the same for every target
— the `N`-invariant universal exclusion table of the Berggren root orbit — has exactly
zero mutual information with the target. -/
theorem mutualInfo_of_constant {p : α → β → ℝ} {y₀ : β}
    (htot : ∑ x, ∑ y, p x y = 1) (hconst : ∀ x, ∀ y, y ≠ y₀ → p x y = 0) :
    mutualInfo p = 0 := by
  have hx : ∀ x, marginalX p x = p x y₀ := by
    intro x
    refine Finset.sum_eq_single y₀ (fun y _ hy => hconst x y hy) (by simp)
  have hy : marginalY p y₀ = 1 := marginalY_of_constant htot hconst
  refine Finset.sum_eq_zero (fun x _ => ?_)
  refine Finset.sum_eq_zero (fun y _ => ?_)
  by_cases hyy : y = y₀
  · subst hyy
    rcases eq_or_ne (p x y) 0 with h0 | h0
    · simp [h0]
    · have : p x y / (marginalX p x * marginalY p y) = 1 := by
        rw [hx, hy, mul_one, div_self h0]
      rw [this, Real.log_one, mul_zero]
  · simp [hconst x y hyy]


omit [Fintype α] in
/-- Marginals of a nonnegative joint law are nonnegative. -/
lemma marginalX_nonneg {p : α → β → ℝ} (hp : ∀ x y, 0 ≤ p x y) (x : α) : 0 ≤ marginalX p x :=
  Finset.sum_nonneg fun y _ => hp x y

omit [Fintype β] in
lemma marginalY_nonneg {p : α → β → ℝ} (hp : ∀ x y, 0 ≤ p x y) (y : β) : 0 ≤ marginalY p y :=
  Finset.sum_nonneg fun x _ => hp x y

omit [Fintype α] in
/-- Each entry is dominated by its row marginal. -/
lemma le_marginalX {p : α → β → ℝ} (hp : ∀ x y, 0 ≤ p x y) (x : α) (y : β) :
    p x y ≤ marginalX p x :=
  Finset.single_le_sum (f := fun y => p x y) (fun y _ => hp x y) (Finset.mem_univ y)

omit [Fintype β] in
lemma le_marginalY {p : α → β → ℝ} (hp : ∀ x y, 0 ≤ p x y) (x : α) (y : β) :
    p x y ≤ marginalY p y :=
  Finset.single_le_sum (f := fun x => p x y) (fun x _ => hp x y) (Finset.mem_univ x)

/-- Pointwise Gibbs bound: every cell of the mutual-information sum is bounded below by
the corresponding cell of `p - p_X p_Y`, whose total is zero. -/
lemma mutualInfo_term_ge {p : α → β → ℝ} (hp : ∀ x y, 0 ≤ p x y) (x : α) (y : β) :
    p x y - marginalX p x * marginalY p y ≤
      p x y * Real.log (p x y / (marginalX p x * marginalY p y)) := by
  rcases eq_or_lt_of_le (hp x y) with h0 | hpos
  · have hm : 0 ≤ marginalX p x * marginalY p y :=
      mul_nonneg (marginalX_nonneg hp x) (marginalY_nonneg hp y)
    rw [← h0]
    simpa using hm
  · have hmx : 0 < marginalX p x := lt_of_lt_of_le hpos (le_marginalX hp x y)
    have hmy : 0 < marginalY p y := lt_of_lt_of_le hpos (le_marginalY hp x y)
    have hm : 0 < marginalX p x * marginalY p y := mul_pos hmx hmy
    set r : ℝ := p x y / (marginalX p x * marginalY p y) with hr
    have hrpos : 0 < r := div_pos hpos hm
    -- `log (1/r) ≤ 1/r - 1`, i.e. `log r ≥ 1 - 1/r`
    have hlog : Real.log r⁻¹ ≤ r⁻¹ - 1 := Real.log_le_sub_one_of_pos (by positivity)
    have hlog' : 1 - r⁻¹ ≤ Real.log r := by
      rw [Real.log_inv] at hlog; linarith
    have hmul : p x y * (1 - r⁻¹) ≤ p x y * Real.log r := by
      exact mul_le_mul_of_nonneg_left hlog' hpos.le
    have hinv : p x y * r⁻¹ = marginalX p x * marginalY p y := by
      rw [hr]
      field_simp
    calc p x y - marginalX p x * marginalY p y
        = p x y * (1 - r⁻¹) := by rw [mul_sub, mul_one, hinv]
      _ ≤ p x y * Real.log r := hmul

/-- **Nonnegativity of mutual information** (finite Gibbs inequality).  Hence the orbit
dial's value `0` is the absolute floor: it is *exactly* as uninformative as possible. -/
theorem mutualInfo_nonneg {p : α → β → ℝ} (hp : ∀ x y, 0 ≤ p x y)
    (htot : ∑ x, ∑ y, p x y = 1) : 0 ≤ mutualInfo p := by
  have hmxsum : ∑ x, marginalX p x = 1 := htot
  have hmysum : ∑ y, marginalY p y = 1 := by
    rw [show (∑ y, marginalY p y) = ∑ y, ∑ x, p x y from rfl, Finset.sum_comm]
    exact htot
  have hprod : ∑ x, ∑ y, marginalX p x * marginalY p y = 1 := by
    have hstep : ∑ x, ∑ y, marginalX p x * marginalY p y
        = (∑ x, marginalX p x) * ∑ y, marginalY p y := by
      rw [Finset.sum_mul]
      exact Finset.sum_congr rfl fun x _ => (Finset.mul_sum _ _ _).symm
    rw [hstep, hmxsum, hmysum, mul_one]
  have hlow : ∑ x, ∑ y, (p x y - marginalX p x * marginalY p y) ≤ mutualInfo p := by
    refine Finset.sum_le_sum (fun x _ => Finset.sum_le_sum (fun y _ => ?_))
    exact mutualInfo_term_ge hp x y
  have hzero : ∑ x, ∑ y, (p x y - marginalX p x * marginalY p y) = 0 := by
    have h1 : ∑ x, ∑ y, (p x y - marginalX p x * marginalY p y)
        = (∑ x, ∑ y, p x y) - ∑ x, ∑ y, marginalX p x * marginalY p y := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun x _ => Finset.sum_sub_distrib _ _
    rw [h1, htot, hprod, sub_self]
  linarith [hlow, hzero.le, hzero.ge]

/-- A perfectly correlated pair on two equiprobable classes: the model of an ordinary
one-bit residue dial such as `N mod 4 ↦ (p mod 4, q mod 4)`. -/
noncomputable def perfectPair : Fin 2 → Fin 2 → ℝ := fun x y => if x = y then 1 / 2 else 0

@[simp] lemma perfectPair_marginalX (x : Fin 2) : marginalX perfectPair x = 1 / 2 := by
  fin_cases x <;> simp [marginalX, perfectPair]

@[simp] lemma perfectPair_marginalY (y : Fin 2) : marginalY perfectPair y = 1 / 2 := by
  fin_cases y <;> simp [marginalY, perfectPair]

/-- **One bit of genuine content.**  The perfectly correlated residue dial has mutual
information `log 2` — exactly one bit — in sharp contrast with the orbit dial. -/
theorem perfectPair_mutualInfo : mutualInfo perfectPair = Real.log 2 := by
  have hval : ((1 : ℝ) / 2) / ((1 / 2) * (1 / 2)) = 2 := by norm_num
  simp only [mutualInfo, Fin.sum_univ_two, perfectPair_marginalX, perfectPair_marginalY,
    perfectPair]
  norm_num [hval]
  ring

/-- Mutual information measured in bits. -/
noncomputable def bits (x : ℝ) : ℝ := x / Real.log 2

/-- The residue dial is worth exactly one bit. -/
theorem perfectPair_one_bit : bits (mutualInfo perfectPair) = 1 := by
  rw [bits, perfectPair_mutualInfo, div_self (Real.log_ne_zero_of_pos_of_ne_one (by norm_num)
    (by norm_num))]

/-- The joint law of (target class, orbit-dial output): the target class is uniform on
two values, and the dial always reveals the same symbol, because the Berggren root
component's revealed residue table `{(1,0,1),(3,0,1)}` does not depend on the target
(see `OrbitDialCap.Berggren.revealed_mod4_eq`). -/
noncomputable def orbitJoint : Fin 2 → Fin 2 → ℝ := fun _ y => if y = 0 then 1 / 2 else 0

lemma orbitJoint_total : ∑ x, ∑ y, orbitJoint x y = 1 := by
  simp [orbitJoint]

lemma orbitJoint_const : ∀ x, ∀ y, y ≠ (0 : Fin 2) → orbitJoint x y = 0 := by
  intro x y hy; simp [orbitJoint, hy]

/-- The orbit dial carries zero information about the target. -/
theorem orbitJoint_mutualInfo : mutualInfo orbitJoint = 0 :=
  mutualInfo_of_constant orbitJoint_total orbitJoint_const

/-- The orbit dial is worth exactly zero bits. -/
theorem orbitJoint_zero_bits : bits (mutualInfo orbitJoint) = 0 := by
  rw [orbitJoint_mutualInfo]
  simp [bits]

/-- **Synthesis (H1 confirmed, H2 gate false).**

1. the orbit dial has exactly zero mutual information with the target;
2. an ordinary residue dial has a full bit;
3. the orbit dial nevertheless reads `2 > 4/3` at retention `θ = 1/2`, because it is a
   *deterministic* exclusion (soundness `1`, `Berggren.parity_dial_sound`);
4. every exchangeable — i.e. information-bearing rather than structural — dial obeys
   the `4/3` cap.

So the `2.0000` read is a constant shave from a blind structural exclusion, and the
cap law (barrier 4) stands, with its scope now delimited. -/
theorem orbit_dial_constant_shave :
    bits (mutualInfo orbitJoint) = 0 ∧
    bits (mutualInfo perfectPair) = 1 ∧
    OrbitDialCap.dialSpeedup 1 (1 / 2) = 2 ∧
    4 / 3 < OrbitDialCap.dialSpeedup 1 (1 / 2) ∧
    (∀ θ : ℝ, 0 < θ → θ ≤ 1 → OrbitDialCap.dialSpeedup θ θ ≤ 4 / 3) := by
  refine ⟨orbitJoint_zero_bits, perfectPair_one_bit, OrbitDialCap.parity_skip_speedup, ?_,
    fun θ hθ hθ1 => OrbitDialCap.exchangeable_cap hθ hθ1⟩
  rw [OrbitDialCap.parity_skip_speedup]; norm_num

/-- The escape route is soundness, not information: the orbit dial breaks the cap
because it satisfies the sharp criterion `s (1 - θ) > 1/4` with `s = 1`, while any
exchangeable dial has `θ (1 - θ) ≤ 1/4`. -/
theorem escape_is_soundness :
    (1 : ℝ) * (1 - 1 / 2) > 1 / 4 ∧ (1 / 2 : ℝ) * (1 - 1 / 2) ≤ 1 / 4 := by
  constructor <;> norm_num

/-- The orbit dial sits exactly on the information floor. -/
theorem orbit_dial_attains_floor :
    mutualInfo orbitJoint = 0 ∧
      ∀ p : Fin 2 → Fin 2 → ℝ, (∀ x y, 0 ≤ p x y) → (∑ x, ∑ y, p x y = 1) →
        mutualInfo orbitJoint ≤ mutualInfo p := by
  refine ⟨orbitJoint_mutualInfo, fun p hp htot => ?_⟩
  rw [orbitJoint_mutualInfo]
  exact mutualInfo_nonneg hp htot

end Info
end OrbitDialCap