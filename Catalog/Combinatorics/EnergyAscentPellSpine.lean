import Mathlib
import Combinatorics.EnergyAscentFermatWindow

/-!
# Energy-Ascent IV: the `B₂`-spine realises the window channel

The bridge theorem `EnergyAscent.window_hit_determines_berggren_letter` says
that a Fermat-window hit on the legs of a primitive Pythagorean triple pins its
Berggren branch letter.  A theorem of that shape is worthless if its hypotheses
are never met, so here we exhibit an explicit infinite family that meets them:
the **`B₂`-spine** of the Berggren tree, obtained by iterating the middle
generator from the root `(3, 4, 5)`.

Its members `(3,4,5), (21,20,29), (119,120,169), (697,696,985), …` have legs
differing by exactly `1`; hence they are automatically primitive, they are
window hits for the *smallest possible* window `W = 1`, and their hypotenuses
grow geometrically.  So the magnitude channel of Energy-Ascent III fires
infinitely often, and every time it fires it reads the letter correctly.

## Main results

* `EnergyAscent.spine_invariants`: the spine consists of primitive Pythagorean
  triples with `(a − b)² = 1` and geometric growth.
* `EnergyAscent.spine_is_window_hit`: every spine member is a `W = 1` window hit.
* `EnergyAscent.bridge_nonvacuous`: at every scale there is a primitive
  Pythagorean triple to which the bridge theorem applies, and whose branch
  letter it correctly determines to be `1`.
-/

namespace EnergyAscent

/-- The `B₂`-spine of the Berggren tree: iterate the middle Barning–Hall
generator starting from the root `(3, 4, 5)`. -/
def spine : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 => B2 (spine n).1 (spine n).2.1 (spine n).2.2

@[simp] theorem spine_zero : spine 0 = (3, 4, 5) := rfl

theorem spine_succ (n : ℕ) :
    spine (n + 1) = B2 (spine n).1 (spine n).2.1 (spine n).2.2 := rfl

/-- The structural invariants of the spine, proved by a single induction:
positivity, the Pythagorean relation, unit leg gap, and linear growth of the
hypotenuse. -/
theorem spine_invariants (n : ℕ) :
    0 < (spine n).1 ∧ 0 < (spine n).2.1 ∧ 0 < (spine n).2.2 ∧
      IsPT (spine n).1 (spine n).2.1 (spine n).2.2 ∧
      ((spine n).1 - (spine n).2.1) ^ 2 = 1 ∧
      (n : ℤ) + 5 ≤ (spine n).2.2 := by
  induction n with
  | zero => refine ⟨by norm_num, by norm_num, by norm_num, ?_, by norm_num, by norm_num⟩
            unfold IsPT; norm_num
  | succ n ih =>
    obtain ⟨ha, hb, hc, hpt, hgap, hgrow⟩ := ih
    have hlt : (spine n).2.2 < (spine n).1 + (spine n).2.1 := hyp_lt_sum ha hb hc hpt
    refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
    · rw [spine_succ]; simp only [B2]; omega
    · rw [spine_succ]; simp only [B2]; omega
    · rw [spine_succ]; simp only [B2]; omega
    · rw [spine_succ]; exact B2_isPT hpt
    · rw [spine_succ]; simp only [B2]; linear_combination hgap
    · rw [spine_succ]; simp only [B2]; push_cast; omega

/-- Restatement of the unit-gap invariant. -/
theorem spine_gap (n : ℕ) : ((spine n).1 - (spine n).2.1) ^ 2 = 1 :=
  (spine_invariants n).2.2.2.2.1

/-- Spine members are primitive: consecutive integers are coprime. -/
theorem spine_primitive (n : ℕ) : Int.gcd (spine n).1 (spine n).2.1 = 1 := by
  have h := spine_gap n
  have hcop : IsCoprime (spine n).1 (spine n).2.1 :=
    ⟨(spine n).1 - (spine n).2.1, -((spine n).1 - (spine n).2.1), by linear_combination h⟩
  exact Int.isCoprime_iff_gcd_eq_one.mp hcop

/-- A factor pair with unit gap is a window hit for the smallest window `W = 1`. -/
theorem unit_gap_hit {p : ℤ} (hp : 0 < p) :
    fermatOffset (p : ℝ) ((p : ℝ) + 1) ≤ (1 : ℝ) := by
  have hpR : (1 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp
  have hsq : (1 : ℝ) ≤ Real.sqrt ((p : ℝ) * ((p : ℝ) + 1)) := by
    have h := Real.sqrt_le_sqrt (show (1 : ℝ) ≤ (p : ℝ) * ((p : ℝ) + 1) by nlinarith)
    rwa [Real.sqrt_one] at h
  refine balanced_implies_hit (by linarith) (by linarith) ?_
  have hone : ((p : ℝ) + 1 - p) ^ 2 = 1 := by ring
  rw [hone]
  nlinarith [hsq]

/-- Every spine member, written with its legs in increasing order, is a
primitive Pythagorean triple whose legs are consecutive integers. -/
theorem spine_sorted (n : ℕ) :
    ∃ p c : ℤ, 0 < p ∧ 0 < c ∧ IsPT p (p + 1) c ∧ Int.gcd p (p + 1) = 1 ∧
      (n : ℤ) + 5 ≤ c ∧ c < p + (p + 1) := by
  obtain ⟨ha, hb, hc, hpt, hgap, hgrow⟩ := spine_invariants n
  set a := (spine n).1
  set b := (spine n).2.1
  set c := (spine n).2.2
  have hlt : c < a + b := hyp_lt_sum ha hb hc hpt
  have h1 : a - b ≤ 1 := by nlinarith
  have h2 : -1 ≤ a - b := by nlinarith
  have h3 : a - b ≠ 0 := by
    intro h
    rw [h] at hgap
    norm_num at hgap
  have hcases : a = b + 1 ∨ b = a + 1 := by omega
  have hcop : ∀ x : ℤ, Int.gcd x (x + 1) = 1 := by
    intro x
    exact Int.isCoprime_iff_gcd_eq_one.mp ⟨-1, 1, by ring⟩
  rcases hcases with h | h
  · refine ⟨b, c, hb, hc, ?_, hcop b, hgrow, by omega⟩
    unfold IsPT at hpt ⊢
    rw [← h]
    linarith [hpt]
  · exact ⟨a, c, ha, hc, by rw [← h]; exact hpt, hcop a, hgrow, by omega⟩

/-- **The bridge is non-vacuous.**  At every scale there is a primitive
Pythagorean triple whose leg pair is a `W = 1` Fermat-window hit above the
threshold scale `112`, and for which the magnitude channel of
`window_hit_determines_berggren_letter` therefore reads off the branch letter
`1` — the middle Berggren generator — correctly. -/
theorem bridge_nonvacuous (S : ℤ) :
    ∃ a b c : ℤ, S < b ∧ 112 ≤ b ∧ 0 < a ∧ a ≤ b ∧ 0 < c ∧ IsPT a b c ∧
      Int.gcd a b = 1 ∧ fermatOffset (a : ℝ) (b : ℝ) ≤ (1 : ℝ) ∧
      branchLetter a b = 1 ∧
      (0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2) := by
  obtain ⟨n, hn⟩ : ∃ n : ℕ, max (2 * S) 224 ≤ (n : ℤ) := ⟨(max (2 * S) 224).toNat, by omega⟩
  obtain ⟨p, c, hp, hc, hpt, hcop, hgrow, hsum⟩ := spine_sorted n
  have hS : 2 * S ≤ (n : ℤ) := le_trans (le_max_left _ _) hn
  have h224 : (224 : ℤ) ≤ (n : ℤ) := le_trans (le_max_right _ _) hn
  have hpbig : 112 ≤ p := by omega
  have hhit : fermatOffset (p : ℝ) ((p : ℝ) + 1) ≤ (1 : ℝ) := unit_gap_hit hp
  have hcast : ((p + 1 : ℤ) : ℝ) = (p : ℝ) + 1 := by push_cast; ring
  obtain ⟨hletter, hparent⟩ :=
    window_hit_determines_berggren_letter (a := p) (b := p + 1) (c := c) (W := 1)
      hp (by omega) hc hpt hcop (by norm_num) (by omega) (by rw [hcast]; simpa using hhit)
  exact ⟨p, p + 1, c, by omega, by omega, hp, by omega, hc, hpt, hcop,
    by rw [hcast]; simpa using hhit, hletter, hparent⟩

end EnergyAscent