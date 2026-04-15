/-! # CatalogBuild.Speculative.Other.NewHypothesesResearch

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 21
-/

import Mathlib

noncomputable section

/-- NH1a: Meet of commuting idempotents is idempotent. -/
theorem idem_meet_idempotent {X : Type*} (f g : X → X)
    (hf : ∀ x, f (f x) = f x) (hg : ∀ x, g (g x) = g x)
    (hcomm : ∀ x, f (g x) = g (f x)) :
    ∀ x, (f ∘ g) ((f ∘ g) x) = (f ∘ g) x := by
  intro x
  simp only [Function.comp]
  rw [show g (f (g x)) = f (g (g x)) from (hcomm (g x)).symm, hg, hf]

/-
NH1b: Fixed points of meet = intersection of fixed points.
-/

theorem idem_meet_fixed {X : Type*} (f g : X → X)
    (hf : ∀ x, f (f x) = f x) (hg : ∀ x, g (g x) = g x)
    (hcomm : ∀ x, f (g x) = g (f x)) :
    {x | (f ∘ g) x = x} = {x | f x = x} ∩ {x | g x = x} := by
  ext x;
  grind


theorem tropical_no_cancellation :
    ¬(∀ a b c : ℝ, max a c = max b c → a = b) := by
  push_neg
  exact ⟨0, 1, 2, by norm_num, by norm_num⟩

/-- In tropical arithmetic, the "zero test" max(a, 0) = 0 characterizes
    nonpositive elements. This is ReLU returning 0. -/

theorem tropical_zero_test (a : ℝ) : max a 0 = 0 ↔ a ≤ 0 := by
  constructor
  · intro h; linarith [le_max_left a 0]
  · intro h; simp [max_eq_right h]

/-- ReLU composed with negation and ReLU decomposes any real number:
    x = ReLU(x) - ReLU(-x). This is the "tropical Peirce decomposition." -/

theorem tropical_peirce (x : ℝ) : x = max x 0 - max (-x) 0 := by
  rcases le_or_gt x 0 with h | h
  · simp [max_eq_right h, max_eq_left (neg_nonneg.mpr h)]
  · simp [max_eq_left h.le, max_eq_right (neg_nonpos.mpr h.le)]

end NH2

-- ═══════════════════════════════════════════════════════════════════════════════
-- NH3: Peirce Decomposition Properties
-- ═══════════════════════════════════════════════════════════════════════════════

section NH3

/-
The Peirce decomposition: every ring element splits into four pieces.
-/

theorem peirce_decomposition {R : Type*} [Ring R] (e : R) (he : e * e = e) (x : R) :
    x = e * x * e + e * x * (1 - e) + (1 - e) * x * e + (1 - e) * x * (1 - e) := by
  simp +decide [ mul_sub, sub_mul, ← mul_assoc, he ]

/-
NH3: The idempotent complement 1 - e is idempotent.
-/

theorem complement_idempotent {R : Type*} [Ring R] (e : R) (he : e * e = e) :
    (1 - e) * (1 - e) = 1 - e := by
  simp +decide [ sub_mul, mul_sub, he ]

/-
The product of an idempotent with its complement is zero.
-/

theorem idem_complement_zero {R : Type*} [Ring R] (e : R) (he : e * e = e) :
    e * (1 - e) = 0 := by
  rw [ mul_sub, mul_one, he, sub_self ]


theorem idemCount_2 : idemCount 2 = 2 := by native_decide

theorem idemCount_3 : idemCount 3 = 2 := by native_decide

theorem idemCount_5 : idemCount 5 = 2 := by native_decide

theorem idemCount_6 : idemCount 6 = 4 := by native_decide

theorem idemCount_7 : idemCount 7 = 2 := by native_decide

theorem idemCount_10 : idemCount 10 = 4 := by native_decide

theorem idemCount_15 : idemCount 15 = 4 := by native_decide

theorem idemCount_30 : idemCount 30 = 8 := by native_decide

end NH4

-- ═══════════════════════════════════════════════════════════════════════════════
-- NH5: Photon Direction Parity (verified)
-- ═══════════════════════════════════════════════════════════════════════════════

section NH5

/-
Pythagorean quadruples have even total sum.
-/

theorem photon_parity (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    2 ∣ (a + b + c + d) := by
  exact even_iff_two_dvd.mp ( by apply_fun Even at *; simp_all +decide [ parity_simps ] )

/-- The stereographic preimage of 1/2 gives the (3,4,5) triple. -/

theorem critical_line_triple :
    (2 * (1/2 : ℚ)) / (1 + (1/2)^2) = 4/5 ∧
    (1 - (1/2 : ℚ)^2) / (1 + (1/2)^2) = 3/5 := by
  norm_num


theorem finite_idempotent_fixed_point {α : Type*} [Finite α] [Nonempty α]
    (f : α → α) (hf : ∀ x, f (f x) = f x) :
    ∃ x : α, f x = x := by
  exact ⟨ f ( Classical.arbitrary α ), hf _ ⟩


/-- The "entropy" of an idempotent on Fin n: the log of the size of Fix(f). -/
def idempotent_entropy (n : ℕ) (f : Fin n → Fin n) : ℝ :=
  Real.log ((Finset.univ.filter (fun x : Fin n => f x = x)).card : ℝ)

/-
The entropy of a constant map (total collapse) is 0 (since exactly 1 fixed point).
-/

theorem entropy_constant (n : ℕ) (hn : 1 < n) (c : Fin n) :
    idempotent_entropy n (fun _ => c) = 0 := by
  unfold idempotent_entropy;
  rw [ Finset.card_eq_one.mpr ] <;> aesop


end
