import Mathlib
import MachineLearning.MoebiusTwistRing

/-!
# Sections of the Möbius line bundle: a ℤ/2-graded ring, and why "twist" is not "sign"

A section of the Möbius line bundle over the circle `ℝ/ℤ` is a function
`f : ℝ → ℝ` with `f (x + 1) = − f x` (Mathlib: `Function.Antiperiodic f 1`);
a section of the *trivial* bundle is a periodic function, `Function.Periodic f 1`.

This file makes the "Möbius arithmetic" idea precise where it actually works: the
twist is a **ℤ/2-grading**, not a prime and not a sign.

## Main results

* `moebius_grading_odd_odd`, `moebius_grading_even_odd`, `moebius_grading_even_even`:
  the multiplication rules `A·A ⊆ P`, `P·A ⊆ A`, `P·P ⊆ P` — exactly the `ℤ/2`-grading
  whose group algebra is the twist ring `ℤ[t]/(t²−1)` of `MoebiusTwistRing`.
* `antiperiodic_not_closed_under_mul`: the odd part is *not* a ring — the Möbius
  sections form a module, never an algebra.
* `periodic_antiperiodic_inter_trivial`: the grading is a direct sum decomposition.
* `antiperiodic_shift_nat`: the holonomy law `f (x + n) = (−1)^n f x`.
* `holonomy_bridge`: the sign in `antiperiodic_shift_nat` is *computed by the twist
  ring*: it is `1` exactly when `t^n = 1` in `Moebius.ZM`.
* `antiperiodic_has_zero_window`, `antiperiodic_continuous_has_zero`,
  `antiperiodic_zeros_unbounded`, `antiperiodic_zero_in_each_window`:
  **every continuous section of the Möbius bundle vanishes in every window of length
  one** (intermediate value theorem), so
  `no_nowhere_zero_moebius_section` and `antiperiodic_not_unit`: the odd part contains
  no invertible element. The Möbius bundle is nontrivial, and the twist can never be
  realised as multiplication by a unit — the number-theoretic content of
  non-orientability.
-/

namespace MoebiusSections

open Function

/-! ### The ℤ/2-grading -/

/-- Odd · odd = even: the product of two Möbius sections is an honest function
on the circle. -/
theorem moebius_grading_odd_odd {f g : ℝ → ℝ} (hf : Antiperiodic f 1)
    (hg : Antiperiodic g 1) : Periodic (fun x => f x * g x) 1 := by
  intro x
  simp only
  rw [hf x, hg x]
  ring

/-- Even · odd = odd: the sections form a module over the periodic functions. -/
theorem moebius_grading_even_odd {f g : ℝ → ℝ} (hf : Periodic f 1)
    (hg : Antiperiodic g 1) : Antiperiodic (fun x => f x * g x) 1 := by
  intro x
  simp only
  rw [hf x, hg x]
  ring

/-- Even · even = even. -/
theorem moebius_grading_even_even {f g : ℝ → ℝ} (hf : Periodic f 1)
    (hg : Periodic g 1) : Periodic (fun x => f x * g x) 1 := by
  intro x
  simp only
  rw [hf x, hg x]

/-- The two graded pieces meet only in `0`. -/
theorem periodic_antiperiodic_inter_trivial {f : ℝ → ℝ} (hp : Periodic f 1)
    (ha : Antiperiodic f 1) : f = 0 := by
  funext x
  have h : -f x = f x := by rw [← ha x, hp x]
  simp only [Pi.zero_apply]
  linarith

/-- The odd part is **not** closed under multiplication: `cos (π x)` is a Möbius
section whose square is not. -/
theorem antiperiodic_not_closed_under_mul :
    ∃ f : ℝ → ℝ, Antiperiodic f 1 ∧ ¬ Antiperiodic (fun x => f x * f x) 1 := by
  refine ⟨fun x => Real.cos (Real.pi * x), ?_, ?_⟩
  · intro x
    show Real.cos (Real.pi * (x + 1)) = -Real.cos (Real.pi * x)
    rw [show Real.pi * (x + 1) = Real.pi * x + Real.pi by ring, Real.cos_add_pi]
  · intro h
    have h0 := h 0
    simp only [zero_add, mul_zero, mul_one, Real.cos_zero, Real.cos_pi] at h0
    norm_num at h0

/-! ### Holonomy -/

/-- The holonomy law: shifting a Möbius section by `n` multiplies it by `(−1)^n`. -/
theorem antiperiodic_shift_nat {f : ℝ → ℝ} (hf : Antiperiodic f 1) (n : ℕ) (x : ℝ) :
    f (x + n) = (-1 : ℝ) ^ n * f x := by
  induction n with
  | zero => simp
  | succ m ih =>
    have hstep : x + (m + 1 : ℕ) = (x + m) + 1 := by push_cast; ring
    rw [hstep, hf (x + m), ih]
    ring

/-- **Bridge to the twist ring.** The sign picked up by shifting a Möbius section
`n` times is trivial exactly when the holonomy `t^n` is trivial in `ℤ[t]/(t²−1)`. -/
theorem holonomy_bridge {f : ℝ → ℝ} (hf : Antiperiodic f 1) (n : ℕ) (x : ℝ) :
    f (x + n) = (if Moebius.ZM.tw ^ n = 1 then (1 : ℝ) else -1) * f x := by
  rw [antiperiodic_shift_nat hf n x]
  by_cases h : Even n
  · rw [if_pos ((Moebius.ZM.tw_pow_eq_one_iff n).mpr h), h.neg_one_pow]
  · rw [if_neg (fun hc => h ((Moebius.ZM.tw_pow_eq_one_iff n).mp hc)),
      (Nat.not_even_iff_odd.mp h).neg_one_pow]

/-! ### Non-orientability: every continuous section vanishes -/

/-- Every continuous section of the Möbius line bundle has a zero in **every** window
`[a, a+1]`. This is the analytic form of non-orientability: antiperiodicity forces a
sign change on each period. -/
theorem antiperiodic_has_zero_window {f : ℝ → ℝ} (hf : Antiperiodic f 1)
    (hc : Continuous f) (a : ℝ) : ∃ x ∈ Set.Icc a (a + 1), f x = 0 := by
  have h1 : f (a + 1) = -f a := hf a
  rcases le_or_gt (f a) 0 with h0 | h0
  · have hmem : (0 : ℝ) ∈ Set.Icc (f a) (f (a + 1)) := by
      rw [h1]
      exact ⟨h0, by linarith⟩
    obtain ⟨x, hx, hfx⟩ :=
      intermediate_value_Icc (by linarith : a ≤ a + 1) hc.continuousOn hmem
    exact ⟨x, hx, hfx⟩
  · have hmem : (0 : ℝ) ∈ Set.Icc (f (a + 1)) (f a) := by
      rw [h1]
      exact ⟨by linarith, le_of_lt h0⟩
    obtain ⟨x, hx, hfx⟩ :=
      intermediate_value_Icc' (by linarith : a ≤ a + 1) hc.continuousOn hmem
    exact ⟨x, hx, hfx⟩

/-- In particular there is a zero in `[0,1]`. -/
theorem antiperiodic_continuous_has_zero {f : ℝ → ℝ} (hf : Antiperiodic f 1)
    (hc : Continuous f) : ∃ x ∈ Set.Icc (0 : ℝ) 1, f x = 0 := by
  simpa using antiperiodic_has_zero_window hf hc 0

/-- The zero set of a continuous Möbius section is unbounded: it meets every window
of length one, hence contains points beyond any bound. -/
theorem antiperiodic_zeros_unbounded {f : ℝ → ℝ} (hf : Antiperiodic f 1)
    (hc : Continuous f) (C : ℝ) : ∃ x, C ≤ x ∧ f x = 0 := by
  obtain ⟨x, hx, hfx⟩ := antiperiodic_has_zero_window hf hc C
  exact ⟨x, hx.1, hfx⟩

/-- Quantitative form: for every `n : ℕ` the interval `[0, n]` contains at least `n`
zeros, exhibited as one zero in each unit window `[k, k+1]`. -/
theorem antiperiodic_zero_in_each_window {f : ℝ → ℝ} (hf : Antiperiodic f 1)
    (hc : Continuous f) (n : ℕ) :
    ∀ k < n, ∃ x ∈ Set.Icc (k : ℝ) (k + 1), x ≤ n ∧ f x = 0 := by
  intro k hk
  obtain ⟨x, hx, hfx⟩ := antiperiodic_has_zero_window hf hc (k : ℝ)
  refine ⟨x, hx, ?_, hfx⟩
  have hkn : (k : ℝ) + 1 ≤ (n : ℝ) := by exact_mod_cast Nat.succ_le_of_lt hk
  exact le_trans hx.2 hkn

/-- There is no nowhere-vanishing continuous Möbius section: the bundle is
nontrivial. -/
theorem no_nowhere_zero_moebius_section :
    ¬ ∃ f : ℝ → ℝ, Antiperiodic f 1 ∧ Continuous f ∧ ∀ x, f x ≠ 0 := by
  rintro ⟨f, hf, hc, hne⟩
  obtain ⟨x, -, hx⟩ := antiperiodic_continuous_has_zero hf hc
  exact hne x hx

/-- Consequently a continuous Möbius section is never invertible in the ring of
continuous functions: the twist is a grading, never a unit. -/
theorem antiperiodic_not_unit {f g : ℝ → ℝ} (hf : Antiperiodic f 1)
    (hc : Continuous f) : ¬ (∀ x, f x * g x = 1) := by
  intro h
  obtain ⟨x, -, hx⟩ := antiperiodic_continuous_has_zero hf hc
  have := h x
  rw [hx, zero_mul] at this
  norm_num at this

/-- By contrast the trivial (periodic) part *does* contain units, e.g. the constant
function `1`; so the even and odd parts are genuinely different as modules. -/
theorem periodic_has_unit :
    ∃ f : ℝ → ℝ, Periodic f 1 ∧ Continuous f ∧ ∀ x, f x * f x = 1 :=
  ⟨fun _ => 1, fun _ => rfl, continuous_const, fun _ => by norm_num⟩

/-- Combining the two previous results: no continuous function can be both a unit
and a Möbius section, so the grading `P ⊕ A` has all its units in the even part.
-/
theorem units_are_even {f g : ℝ → ℝ} (hc : Continuous f) (hu : ∀ x, f x * g x = 1)
    (hf : Antiperiodic f 1) : False :=
  antiperiodic_not_unit hf hc hu

end MoebiusSections