/-
# Which readouts of Frobenius see the splitting type?  The fixed-root dichotomy

In the experiment, the splitting type of `p` in `ℚ(ζ₁₉)⁺` was cross-checked against the
factorisation of the degree-nine minimal polynomial of `2 cos(2π/19)` over `𝔽_p`.  Two readouts
were available:

* the **fixed-root count** `nr(p)` (number of roots in `𝔽_p`), and
* the **factor-degree pattern** (multiset of degrees of irreducible factors).

Galois-theoretically, the nine roots form a torsor under the Galois group `C₉`, and Frobenius
acts on it by translation.  The pattern is therefore the cycle type of a translation, and the
fixed-root count is its number of fixed points.  This file proves, in the abstract torsor model
and then on the whole abelian ladder:

* `ForkPinning.card_fixed_translation` : a translation `x ↦ h x` of a finite group has
  `|C|` fixed points if `h = 1` and none otherwise — **all non-trivial Frobenius classes fix
  zero roots**.
* `ForkPinning.minimalPeriod_translation` : every cycle of `x ↦ h x` has length `orderOf h` —
  the pattern is `[o^(|C|/o)]` with `o = orderOf h`, so it **is** the splitting type.
* `ForkPinning.fixedRoot_determines_iff` : on the rung of degree `m` (inside a cyclic group of
  order `2m`), the fixed-root readout determines the type **iff `m = 1` or `m` is prime**.
* `ForkPinning.fixedRoot_lossy` : on every composite rung the readout is strictly lossy:
  `I(p ; nr) = H(nr) < H(T)`.
* `ForkPinning.degreeNine_fixedRoot_info` : at degree nine the fixed-root readout carries exactly
  `H(1/9, 8/9)` nats — strictly less than `H(T) = (4/3) log 3 - (8/9) log 2`.
-/

import Probability.ForkPinningDegreeNine

namespace ForkPinning

open Finset Real

/-! ## Translations of a torsor -/

section Torsor

variable {C : Type*} [Group C] [Fintype C] [DecidableEq C]

/-- **Fixed points of a translation**: `|C|` if `h = 1`, otherwise `0`. -/
theorem card_fixed_translation (h : C) :
    #{x : C | h * x = x} = if h = 1 then Fintype.card C else 0 := by
  have hiff : ∀ x : C, h * x = x ↔ h = 1 := fun x => mul_eq_right
  split_ifs with h1
  · rw [Finset.filter_true_of_mem (fun x _ => (hiff x).mpr h1), card_univ]
  · rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
    exact fun x _ hx => h1 ((hiff x).mp hx)

omit [Fintype C] [DecidableEq C] in
/-- **Cycle lengths of a translation**: every point lies on a cycle of length `orderOf h`. -/
theorem minimalPeriod_translation (h x : C) :
    Function.minimalPeriod (fun y => h * y) x = orderOf h := by
  rw [orderOf, Function.minimalPeriod_eq_minimalPeriod_iff]
  intro n
  have hit : ∀ z : C, (fun y => h * y)^[n] z = h ^ n * z := by
    intro z
    induction n generalizing z with
    | zero => simp
    | succ k ih =>
      rw [Function.iterate_succ_apply', ih, pow_succ', mul_assoc]
  simp only [Function.IsPeriodicPt, Function.IsFixedPt, hit, mul_one]
  exact ⟨fun hx => mul_eq_right.mp hx, fun hx => by rw [hx, one_mul]⟩

end Torsor

/-! ## The fixed-root readout on the abelian ladder -/

section Ladder

variable {G : Type*} [CommGroup G] [Fintype G] [DecidableEq G] [IsCyclic G]

/-- The fixed-root readout: does Frobenius fix the roots (`nr = m`) or not (`nr = 0`)? -/
def fixedRoot (g : G) : Bool := decide (g ^ 2 = 1)

omit [IsCyclic G] [DecidableEq G] in
lemma ladderType_eq_one_iff (g : G) : ((ladderType g : ℕ) = 1) ↔ g ^ 2 = 1 := by
  simp [ladderType, orderOf_eq_one_iff]

omit [IsCyclic G] in
/-- The type determines the fixed-root readout. -/
theorem type_determines_fixedRoot :
    Determines (ladderType : G → (Fintype.card G).divisors) fixedRoot := by
  intro g g' h
  simp only [fixedRoot, ← ladderType_eq_one_iff, h]

omit [DecidableEq G] in
/-- Every type `d ∣ m` is realised. -/
lemma exists_ladderType_eq [DecidableEq G] {m d : ℕ} (hG : Fintype.card G = 2 * m)
    (hd : d ∣ m) : ∃ g : G, orderOf (g ^ 2) = d := by
  have hm : 0 < m := by have := Fintype.card_pos (α := G); omega
  have hd0 : 0 < d := Nat.pos_of_dvd_of_pos hd hm
  have hcard := card_orderOf_sq_eq hG hd (G := G)
  have hpos : 0 < #{g : G | orderOf (g ^ 2) = d} := by
    rw [hcard]; have := Nat.totient_pos.mpr hd0; omega
  obtain ⟨g, hg⟩ := Finset.card_pos.mp hpos
  exact ⟨g, by simpa using hg⟩

/-- **The fixed-root dichotomy.**  On the rung of degree `m`, the fixed-root count determines
the splitting type exactly when `m = 1` or `m` is prime. -/
theorem fixedRoot_determines_iff {m : ℕ} (hG : Fintype.card G = 2 * m) :
    Determines (fixedRoot : G → Bool) (ladderType : G → (Fintype.card G).divisors)
      ↔ m = 1 ∨ m.Prime := by
  have hm : 0 < m := by have := Fintype.card_pos (α := G); omega
  constructor
  · intro hdet
    by_contra hcon
    push_neg at hcon
    obtain ⟨h1, hp⟩ := hcon
    have h2 : 2 ≤ m := by omega
    obtain ⟨d, hdm, hd1, hdm'⟩ : ∃ d, d ∣ m ∧ d ≠ 1 ∧ d ≠ m := by
      by_contra hno
      push_neg at hno
      exact hp (Nat.prime_def.mpr ⟨h2, fun d hd => by
        by_cases hd1 : d = 1
        · exact Or.inl hd1
        · exact Or.inr (hno d hd hd1)⟩)
    obtain ⟨g₁, hg₁⟩ := exists_ladderType_eq hG hdm (G := G)
    obtain ⟨g₂, hg₂⟩ := exists_ladderType_eq hG (dvd_refl m) (G := G)
    have a : g₁ ^ 2 ≠ 1 := fun h => hd1 (hg₁ ▸ orderOf_eq_one_iff.mpr h)
    have b : g₂ ^ 2 ≠ 1 := fun h => h1 (hg₂ ▸ orderOf_eq_one_iff.mpr h)
    have hf : fixedRoot g₁ = fixedRoot g₂ := by
      simp only [fixedRoot, a, b, decide_false]
    have := congrArg Subtype.val (hdet g₁ g₂ hf)
    simp only [ladderType] at this
    exact hdm' (hg₁ ▸ hg₂ ▸ this)
  · rintro (h1 | hp) g g' hf
    · apply Subtype.ext
      simp only [ladderType]
      have a := orderOf_sq_dvd hG g
      have b := orderOf_sq_dvd hG g'
      rw [h1, Nat.dvd_one] at a b
      rw [a, b]
    · apply Subtype.ext
      simp only [ladderType]
      have a := (Nat.dvd_prime hp).mp (orderOf_sq_dvd hG g)
      have b := (Nat.dvd_prime hp).mp (orderOf_sq_dvd hG g')
      have hf' : g ^ 2 = 1 ↔ g' ^ 2 = 1 := by simpa [fixedRoot] using hf
      rcases a with a | a <;> rcases b with b | b
      · rw [a, b]
      · exact absurd (orderOf_eq_one_iff.mpr (hf'.mp (orderOf_eq_one_iff.mp a)))
          (by rw [b]; exact hp.one_lt.ne')
      · exact absurd (orderOf_eq_one_iff.mpr (hf'.mpr (orderOf_eq_one_iff.mp b)))
          (by rw [a]; exact hp.one_lt.ne')
      · rw [a, b]

omit [IsCyclic G] in
/-- The fixed-root readout is extracted perfectly by the residue: `I(p ; nr) = H(nr)`, and it
equals the information the type has about it. -/
theorem fixedRoot_pinned :
    mutualInfo (id : G → G) (fixedRoot : G → Bool) = H (fixedRoot : G → Bool) ∧
      mutualInfo (ladderType : G → (Fintype.card G).divisors) (fixedRoot : G → Bool)
        = H (fixedRoot : G → Bool) :=
  ⟨(pinned_iff_determines _ _).mpr (fun g g' h => by rw [show g = g' from h]),
    (pinned_iff_determines _ _).mpr type_determines_fixedRoot⟩

/-- **The fixed-root readout is strictly lossy on every composite rung**:
`H(nr) < H(T)` whenever `m` is neither `1` nor prime. -/
theorem fixedRoot_lossy {m : ℕ} (hG : Fintype.card G = 2 * m) (h1 : m ≠ 1) (hp : ¬ m.Prime) :
    H (fixedRoot : G → Bool) < H (ladderType : G → (Fintype.card G).divisors) := by
  have hnd : ¬ Determines (fixedRoot : G → Bool) (ladderType : G → (Fintype.card G).divisors) :=
    fun h => by
      rcases (fixedRoot_determines_iff hG).mp h with h' | h'
      · exact h1 h'
      · exact hp h'
  have hlt := mutualInfo_lt_entropy_of_not_determines _ _ hnd
  have heq : mutualInfo (fixedRoot : G → Bool) (ladderType : G → (Fintype.card G).divisors)
      = mutualInfo (ladderType : G → (Fintype.card G).divisors) fixedRoot := by
    unfold mutualInfo
    have : H (joint (fixedRoot : G → Bool) (ladderType : G → (Fintype.card G).divisors))
        = H (joint (ladderType : G → (Fintype.card G).divisors) fixedRoot) := by
      have := entropy_congr_equiv (Equiv.prodComm Bool (Fintype.card G).divisors)
        (joint (fixedRoot : G → Bool) (ladderType : G → (Fintype.card G).divisors))
      rw [← this]
      rfl
    rw [this]; ring
  rw [heq, fixedRoot_pinned.2] at hlt
  exact hlt

/-- Probability that Frobenius fixes the roots: `1/m`. -/
theorem prb_fixedRoot_true {m : ℕ} (hG : Fintype.card G = 2 * m) :
    prb (fixedRoot : G → Bool) true = 1 / m := by
  have hm : (0 : ℝ) < m := by
    have := Fintype.card_pos (α := G)
    exact_mod_cast (show 0 < m by omega)
  have hc : (Fintype.card G : ℝ) = 2 * m := by exact_mod_cast hG
  have hfib : fiber (fixedRoot : G → Bool) true = ({g : G | g ^ 2 = 1} : Finset G) := by
    ext g; simp [fiber, fixedRoot]
  rw [prb, hfib, card_sq_eq_one hG, hc]
  push_cast
  field_simp

end Ladder

/-! ## Degree nine: the readout is lossy, the pattern is not -/

section DegreeNine

/-- **At degree nine the fixed-root readout loses information**: it carries exactly
`H(1/9, 8/9)` nats, strictly less than the `H(T) = (4/3) log 3 - (8/9) log 2` carried by the
factor-degree pattern (which, by `minimalPeriod_translation`, is the type itself). -/
theorem degreeNine_fixedRoot_info :
    mutualInfo (id : (ZMod 19)ˣ → (ZMod 19)ˣ) fixedRoot
        = negMulLog (1 / 9) + negMulLog (8 / 9) ∧
      negMulLog (1 / 9) + negMulLog (8 / 9) < 4 / 3 * Real.log 3 - 8 / 9 * Real.log 2 := by
  have htrue : prb (fixedRoot : (ZMod 19)ˣ → Bool) true = 1 / 9 := by
    rw [prb_fixedRoot_true card_units_zmod19]; norm_num
  have hfalse : prb (fixedRoot : (ZMod 19)ˣ → Bool) false = 8 / 9 := by
    have := prb_true_add_false (fixedRoot : (ZMod 19)ˣ → Bool)
    linarith
  have hH : H (fixedRoot : (ZMod 19)ˣ → Bool) = negMulLog (1 / 9) + negMulLog (8 / 9) := by
    rw [H_bool, htrue, hfalse]; ring
  refine ⟨by rw [fixedRoot_pinned.1, hH], ?_⟩
  rw [← hH, ← degreeNine_entropy]
  exact fixedRoot_lossy card_units_zmod19 (by norm_num) (by norm_num)

/-- Degree-nine instance of the dichotomy: `9` is composite, so `nr` does not determine `T`
(orders `3` and `9` both fix zero roots). -/
theorem degreeNine_fixedRoot_not_determines :
    ¬ Determines (fixedRoot : (ZMod 19)ˣ → Bool) T19 := by
  rw [fixedRoot_determines_iff card_units_zmod19]
  norm_num

end DegreeNine

end ForkPinning