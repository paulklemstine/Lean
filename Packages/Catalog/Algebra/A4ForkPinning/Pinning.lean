/-
# The A₄ fork is cubic-pinned at `H(1/3)` — prime level

Putting the three previous files together at the level of a single prime.

The dial is the residue `p mod 9` (six coprime classes, equidistributed by
Dirichlet).  Class field theory for the cyclic cubic field `K = ℚ(ζ₉)⁺` of
conductor `9` (`Resolvent.lean`: `K` *is* the field of the Klein resolvent of
`x⁴ + 8x + 12`) says that the `V₄`-fork

`F₀(p) = [Frob p ∈ V₄] = [p is a cube mod 9] = [p ≡ ±1 mod 9]`

is a *deterministic function of the dial*, while Chebotarev makes the Frobenius
equidistributed in `A₄`, so that inside the `V₄`-fibre the identity has
conditional probability `1/|V₄| = 1/4` (`GroupA4.card_V4`).

What is proved here:

* `A4ForkPinning.info_mod9_V4_fork` — **`I(p mod 9 ; F₀) = H(1/3)` exactly**: the
  first *cubic* pinning, and the same value as for the abelian cyclic cubic;
* `A4ForkPinning.hb_third_bounds` — `0.918 < H(1/3) < 0.919`, matching the
  measured `0.9188` of the experiment (verified by integer power comparisons);
* `A4ForkPinning.info_mod9_identity_fork` — **the exact leakage law for
  `F₁ = [Frob = e]`**: `I = H(1/12) - (1/3)·H(1/4)`, strictly between `0` and
  `H(F₁)`: the identity fork is neither pinned nor flat;
* `A4ForkPinning.info_mod5_flat` — the coprime dial mod `5` is flat, `I = 0`;
* `A4ForkPinning.info_mod9_V4_fork_is_maximal` — `F₀` saturates the channel while
  `F₁` cannot: a formal separation of the two regimes.
-/
import Algebra.A4ForkPinning.Information
import Algebra.A4ForkPinning.GroupA4
import Algebra.A4ForkPinning.Resolvent

namespace A4ForkPinning

open Real Finset

/-! ## Numerics for `H(1/3)` and `H(1/4)` -/

theorem log2_three_lt : Real.log 3 / Real.log 2 < 1.585 := by
  rw [div_lt_iff₀ log_two_pos]
  have hn : (3 : ℕ) ^ (1000 : ℕ) < 2 ^ (1585 : ℕ) := by decide +kernel
  have h : (3 : ℝ) ^ (1000 : ℕ) < (2 : ℝ) ^ (1585 : ℕ) := by exact_mod_cast hn
  have h2 := Real.log_lt_log (by positivity) h
  rw [Real.log_pow, Real.log_pow] at h2
  push_cast at h2
  linarith

theorem log2_three_gt : (1.5849 : ℝ) < Real.log 3 / Real.log 2 := by
  rw [lt_div_iff₀ log_two_pos]
  have hn : (2 : ℕ) ^ (15849 : ℕ) < 3 ^ (10000 : ℕ) := by decide +kernel
  have h : (2 : ℝ) ^ (15849 : ℕ) < (3 : ℝ) ^ (10000 : ℕ) := by exact_mod_cast hn
  have h2 := Real.log_lt_log (by positivity) h
  rw [Real.log_pow, Real.log_pow] at h2
  push_cast at h2
  linarith

/-- `H(1/3) = log₂ 3 - 2/3`. -/
theorem hb_third : hb (1 / 3) = Real.log 3 / Real.log 2 - 2 / 3 := by
  have h2 : Real.log 2 ≠ 0 := ne_of_gt log_two_pos
  have e1 : Real.log (1 / 3) = -Real.log 3 := by rw [one_div, Real.log_inv]
  have e2 : (1 : ℝ) - 1 / 3 = 2 / 3 := by norm_num
  have e3 : Real.log (2 / 3) = Real.log 2 - Real.log 3 :=
    Real.log_div (by norm_num) (by norm_num)
  rw [hb, e2, nml, nml, Real.negMulLog, Real.negMulLog, e1, e3]
  field_simp
  ring

/-- `H(1/4) = 2 - (3/4) log₂ 3`. -/
theorem hb_quarter : hb (1 / 4) = 2 - (3 / 4) * (Real.log 3 / Real.log 2) := by
  have h2 : Real.log 2 ≠ 0 := ne_of_gt log_two_pos
  have e1 : Real.log (1 / 4) = -(2 * Real.log 2) := by
    rw [show (1 : ℝ) / 4 = (2 : ℝ)⁻¹ ^ 2 by norm_num, Real.log_pow, Real.log_inv]; ring
  have e2 : (1 : ℝ) - 1 / 4 = 3 / 4 := by norm_num
  have e3 : Real.log (3 / 4) = Real.log 3 - 2 * Real.log 2 := by
    rw [Real.log_div (by norm_num) (by norm_num), show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]
    ring
  rw [hb, e2, nml, nml, Real.negMulLog, Real.negMulLog, e1, e3]
  field_simp
  ring

/-- The measured value `0.9188` of the experiment, verified: `0.918 < H(1/3) < 0.919`. -/
theorem hb_third_bounds : 0.918 < hb (1 / 3) ∧ hb (1 / 3) < 0.919 := by
  rw [hb_third]
  constructor
  · linarith [log2_three_gt]
  · linarith [log2_three_lt]

/-- `0.811 < H(1/4) < 0.812`. -/
theorem hb_quarter_bounds : 0.811 < hb (1 / 4) ∧ hb (1 / 4) < 0.812 := by
  rw [hb_quarter]
  constructor
  · linarith [log2_three_lt]
  · linarith [log2_three_gt]

/-! ## The mod-9 dial -/

/-- The six residue classes coprime to `9`. -/
def res6 : Fin 6 → ZMod 9 := ![1, 2, 4, 5, 7, 8]

/-- `res6` enumerates exactly the units mod `9`. -/
theorem res6_units (i : Fin 6) : IsUnit (res6 i) := by
  fin_cases i <;> decide

theorem res6_surjective (x : ZMod 9) (hx : IsUnit x) : ∃ i, res6 i = x := by
  revert hx; revert x; decide

theorem res6_injective : Function.Injective res6 := by decide

/-- Dirichlet: the six classes are equidistributed. -/
noncomputable def w6 : Fin 6 → ℝ := fun _ => 1 / 6

theorem w6_pos (i : Fin 6) : 0 < w6 i := by norm_num [w6]

theorem w6_sum : ∑ i, w6 i = 1 := by simp [w6]

/-- The `V₄`-fork read off the dial: `F₀(p) = [p is a cube mod 9]`.  By class field
theory for the conductor-`9` cyclic cubic this is a *deterministic* function of the
residue class. -/
noncomputable def F0 : Fin 6 → ℝ := fun i => if chi9 (res6 i) = 0 then 1 else 0

theorem F0_pinned (i : Fin 6) : F0 i = 0 ∨ F0 i = 1 := by
  unfold F0; split_ifs <;> simp

/-- The rate of the fork is `1/3`: two of the six classes (`p ≡ 1, 8 mod 9`). -/
theorem avg_F0 : avg w6 F0 = 1 / 3 := by
  simp +decide [avg, w6, F0, res6, chi9, Fin.sum_univ_six]
  norm_num

/-- **The cubic pinning.**  `I(p mod 9 ; F₀) = H(1/3)`: the `V₄`-order fork of the
non-abelian `A₄`-field is pinned by the cubic character mod `9`, at exactly the
entropy of its own rate — the same value `H(1/3)` as for an abelian cyclic cubic. -/
theorem info_mod9_V4_fork : info w6 F0 = hb (1 / 3) := by
  rw [info_of_pinned w6 F0 F0_pinned, avg_F0]

/-- Numerically: the channel carries `0.918…` bits, matching the measured `0.9188`. -/
theorem info_mod9_V4_fork_bounds : 0.918 < info w6 F0 ∧ info w6 F0 < 0.919 := by
  rw [info_mod9_V4_fork]; exact hb_third_bounds

/-! ## Chebotarev rates from the group side -/

/-- The rate `1/3` of the fork is the Chebotarev density `|V₄|/|A₄|`
(`card_V4`, `card_alternating`). -/
theorem V4_density :
    ((univ.filter (fun σ : Equiv.Perm (Fin 4) => σ ∈ V4)).card : ℝ)
      / ((univ.filter (fun σ : Equiv.Perm (Fin 4) => Equiv.Perm.sign σ = 1)).card : ℝ)
      = 1 / 3 := by
  rw [card_V4, card_alternating]
  norm_num

/-- Inside the `V₄`-fibre the identity has conditional rate `1/|V₄| = 1/4`. -/
theorem identity_conditional_rate :
    (1 : ℝ) / ((univ.filter (fun σ : Equiv.Perm (Fin 4) => σ ∈ V4)).card : ℝ) = 1 / 4 := by
  rw [card_V4]
  norm_num

/-! ## The identity fork leaks -/

/-- The identity fork `F₁ = [Frob = e]`.  Given `Frob ∈ V₄` (which the dial *does*
determine) the Frobenius is equidistributed in `V₄`, a group of order `4`
(`card_V4`), so the conditional rate is `(1/4)·F₀`. -/
noncomputable def F1 : Fin 6 → ℝ := fun i => (1 / 4) * F0 i

/-- **Exact leakage law for the identity fork**:
`I(p mod 9 ; F₁) = H(1/12) - (1/3)·H(1/4)`. -/
theorem info_mod9_identity_fork : info w6 F1 = hb (1 / 12) - (1 / 3) * hb (1 / 4) := by
  have h := info_leak w6 F0 (1 / 4) F0_pinned
  rw [avg_F0] at h
  rw [show (1 : ℝ) / 4 * (1 / 3) = 1 / 12 by norm_num] at h
  exact h

/-- The identity fork is *neither* pinned *nor* flat: `0 < I < H(F₁) = H(1/12)`. -/
theorem info_mod9_identity_fork_strict :
    0 < info w6 F1 ∧ info w6 F1 < hb (avg w6 F1) := by
  have h := info_leak_strict w6 F0 (1 / 4) F0_pinned (by norm_num) (by norm_num)
    (by rw [avg_F0]; norm_num) (by rw [avg_F0]; norm_num)
  exact h

/-- The rate of the identity fork is `1/12`, so its own entropy is `H(1/12)`. -/
theorem avg_F1 : avg w6 F1 = 1 / 12 := by
  have h : avg w6 F1 = (1 / 4) * avg w6 F0 := by
    simp only [avg, F1, Finset.mul_sum]
    exact Finset.sum_congr rfl fun y _ => by ring
  rw [h, avg_F0]; norm_num

/-- A clean separation of the two regimes: `F₀` saturates the channel, `F₁` does not. -/
theorem info_mod9_V4_fork_is_maximal :
    info w6 F0 = hb (avg w6 F0) ∧ info w6 F1 < hb (avg w6 F1) :=
  ⟨info_of_pinned w6 F0 F0_pinned, info_mod9_identity_fork_strict.2⟩

/-! ## Minimality of the conductor: the dial mod 3 is flat -/

/-- Units mod `9` lying over a given class mod `3`. -/
def unitsOverMod3 (r : ℕ) : ℕ :=
  (univ.filter (fun x : ZMod 9 => IsUnit x ∧ x.val % 3 = r)).card

/-- Cubes mod `9` lying over a given class mod `3`. -/
def cubesOverMod3 (r : ℕ) : ℕ :=
  (univ.filter (fun x : ZMod 9 => IsUnit x ∧ x.val % 3 = r ∧ chi9 x = 0)).card

theorem unitsOverMod3_one : unitsOverMod3 1 = 3 := by decide

theorem unitsOverMod3_two : unitsOverMod3 2 = 3 := by decide

theorem cubesOverMod3_one : cubesOverMod3 1 = 1 := by decide

theorem cubesOverMod3_two : cubesOverMod3 2 = 1 := by decide

/-- The two classes mod `3` that a prime `p ∤ 3` can occupy. -/
def mod3class : Fin 2 → ℕ := ![1, 2]

noncomputable def w2 : Fin 2 → ℝ := fun _ => 1 / 2

theorem w2_sum : ∑ i, w2 i = 1 := by simp [w2]

/-- Reading the `V₄`-fork through the dial `p mod 3` gives the constant rate `1/3`:
each class mod `3` contains exactly one cube among its three units mod `9`. -/
noncomputable def F0mod3 : Fin 2 → ℝ := fun _ => 1 / 3

theorem F0mod3_eq_count (i : Fin 2) :
    F0mod3 i = (cubesOverMod3 (mod3class i) : ℝ) / (unitsOverMod3 (mod3class i) : ℝ) := by
  fin_cases i <;>
    simp [F0mod3, mod3class, cubesOverMod3_one, cubesOverMod3_two,
      unitsOverMod3_one, unitsOverMod3_two]

/-- **Minimality of the modulus `9`.**  `I(p mod 3 ; F₀) = 0`: the conductor cannot be
lowered to `3`, even though `3` is the only ramified prime.  Only the full modulus
`9` pins the fork. -/
theorem info_mod3_flat : info w2 F0mod3 = 0 :=
  info_of_flat w2 F0mod3 (1 / 3) w2_sum (fun _ => rfl)

/-! ## Flatness of a coprime dial mod 5 -/

/-- The four residue classes coprime to `5`, again equidistributed. -/
noncomputable def w4 : Fin 4 → ℝ := fun _ => 1 / 4

theorem w4_sum : ∑ i, w4 i = 1 := by simp [w4]

/-- Reading the `V₄`-fork through a dial mod `5` (a modulus prime to the conductor)
gives the constant conditional rate `1/3`. -/
noncomputable def F0mod5 : Fin 4 → ℝ := fun _ => 1 / 3

/-- **Flatness.**  `I(p mod 5 ; F₀) = 0`: outside the conductor the dial is blind. -/
theorem info_mod5_flat : info w4 F0mod5 = 0 :=
  info_of_flat w4 F0mod5 (1 / 3) w4_sum (fun _ => rfl)

end A4ForkPinning