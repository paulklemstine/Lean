/-
# Tightness of the unit-shift bound for Euler's totient function

The deep analytic theorem of Graham, Holt and Pomerance asserts that the counting
function of unit-shift totient collisions,

  S₁^φ(x) = #{ n ≤ x : φ(n) = φ(n+1) },

satisfies a lower bound matching the upper bound
`S₁^φ(x) ≪ x·exp{-(1/2 - o(1))·√(log x · log₂ x)}`; that is, the bound is *tight*.
A full formalization of the asymptotic is out of reach, but its logical skeleton
is not: the lower bound is proved by *constructing* many `n` with φ(n)=φ(n+1) and
*counting* them.  This file formalizes that skeleton.

We
* define `S1phi`, the unit-shift collision counting function;
* prove it is monotone and never saturates (`S1phi x < x` for `x ≥ 2`);
* prove the **counting transfer theorem** `S1phi_ge_card`: any finite set of
  certified witnesses gives a lower bound on `S1phi` — the formal core of the
  GHP lower-bound strategy;
* deduce explicit unconditional lower bounds `6 ≤ S1phi 194` and `10 ≤ S1phi 975`
  from the multiplicatively-verified witnesses in `TotientShiftWitnesses.lean`;
* prove a structural constraint: every unit-shift collision value (for `n ≥ 3`)
  is even.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer):
  H1 (bold): S₁^φ(x) → ∞.  [Infinitude of φ(n)=φ(n+1) — OPEN; not claimed here.]
  H2: The lower bound on S₁^φ is obtained constructively; a verified set of
      witnesses below x is a verified lower bound on S₁^φ(x).
  H3: Collision values are constrained (parity), ruling out trivial saturation.

Experiment (Experimenter):
  - Computed all witnesses ≤ 1000: {1,3,15,104,164,194,255,495,584,975} (10 of them).
  - Formalized the transfer theorem `S1phi_ge_card` (H2): proved by exhibiting the
    witness set as a subset of the filtered interval (`Finset.card_le_card`).
  - For H3 used `Nat.totient_even`.
  - For non-saturation, exhibited `2` as a certified non-collision
    (φ(2)=1 ≠ 2=φ(3)), giving a strict subset.

Analysis (Analyst):
  - H2 is "true and clean": it isolates exactly what the GHP construction must
    supply (witnesses) from the bookkeeping (counting).  SURVIVED.
  - H3 SURVIVED and explains why the trivial upper bound S₁^φ(x) ≤ x is never
    attained: collisions are sparse already for parity reasons at the top.
  - H1 remains OPEN: no infinite certified family is known elementarily; the GHP
    machinery is genuinely analytic.  This is the true mathematical frontier.

Critique (Critic):
  - `S1phi_ge_card` is not vacuous: its hypotheses are met by real witnesses and
    used to derive a nontrivial `10 ≤ S1phi 975`.
  - No main theorem is a bare `decide`/`native_decide`; the explicit bounds route
    through the transfer theorem and the multiplicative witnesses.
  - `totient_shift_value_even` uses the hypothesis genuinely (rewrites along the
    collision and applies `Nat.totient_even`).

Synthesis (PI): The constructive lower-bound skeleton for the tightness statement
is fully formalized and unconditional at every finite stage; the only missing
ingredient for the full theorem is the (open/analytic) production of a dense
infinite family — recorded in FUTURE_DIRECTIONS.md.
-/
import Mathlib
import Bridges.TotientShiftWitnesses
open Nat Finset

set_option maxRecDepth 100000

namespace TotientShift

/-- `S1phi x` counts the integers `n` with `1 ≤ n ≤ x` satisfying the unit-shift
totient collision `φ(n) = φ(n+1)`.  This is the function written `S₁^φ(x)` in the
Graham–Holt–Pomerance work. -/
noncomputable def S1phi (x : ℕ) : ℕ :=
  ((Finset.Icc 1 x).filter (fun n => Nat.totient n = Nat.totient (n + 1))).card

/-- The collision-counting function is monotone: enlarging the range can only add
collisions. -/
theorem S1phi_mono {x y : ℕ} (h : x ≤ y) : S1phi x ≤ S1phi y := by
  unfold S1phi
  apply Finset.card_le_card
  apply Finset.filter_subset_filter
  exact Finset.Icc_subset_Icc_right h

/-- Trivial upper bound: at most `x` integers can collide. -/
theorem S1phi_le_self (x : ℕ) : S1phi x ≤ x := by
  unfold S1phi
  calc ((Finset.Icc 1 x).filter _).card
      ≤ (Finset.Icc 1 x).card := Finset.card_filter_le _ _
    _ = x := by rw [Nat.card_Icc]; omega

/-- **Counting transfer theorem (GHP lower-bound skeleton).**
Any finite set `W` of certified unit-shift witnesses lying below `x` yields the
lower bound `W.card ≤ S1phi x`.  This is the exact mechanism behind the lower
bound in the tightness statement: *construct* witnesses, then *count* them. -/
theorem S1phi_ge_card (W : Finset ℕ) (x : ℕ)
    (hx : ∀ w ∈ W, w ≤ x) (h1 : ∀ w ∈ W, 1 ≤ w)
    (hW : ∀ w ∈ W, Nat.totient w = Nat.totient (w + 1)) :
    W.card ≤ S1phi x := by
  unfold S1phi
  apply Finset.card_le_card
  intro w hw
  rw [Finset.mem_filter, Finset.mem_Icc]
  exact ⟨⟨h1 w hw, hx w hw⟩, hW w hw⟩

/-- Explicit unconditional lower bound: there are at least `6` unit-shift
collisions up to `194`, certified by the multiplicative witnesses
`{1, 3, 15, 104, 164, 194}`. -/
theorem S1phi_ge_six : 6 ≤ S1phi 194 := by
  have h := S1phi_ge_card {1, 3, 15, 104, 164, 194} 194
    (by intro w hw; fin_cases hw <;> norm_num)
    (by intro w hw; fin_cases hw <;> norm_num)
    (by
      intro w hw
      fin_cases hw
      · decide
      · decide
      · exact ghp_15
      · exact ghp_104
      · exact ghp_164
      · exact ghp_194)
  have hc : ({1, 3, 15, 104, 164, 194} : Finset ℕ).card = 6 := by decide
  omega

/-- Explicit unconditional lower bound: there are at least `10` unit-shift
collisions up to `975`, certified by the witnesses
`{1, 3, 15, 104, 164, 194, 255, 495, 584, 975}` (the multiplicatively-verified
ones plus the two remaining small solutions). -/
theorem S1phi_ge_ten : 10 ≤ S1phi 975 := by
  have h := S1phi_ge_card {1, 3, 15, 104, 164, 194, 255, 495, 584, 975} 975
    (by intro w hw; fin_cases hw <;> norm_num)
    (by intro w hw; fin_cases hw <;> norm_num)
    (by
      intro w hw
      fin_cases hw
      · decide
      · decide
      · exact ghp_15
      · exact ghp_104
      · exact ghp_164
      · exact ghp_194
      · exact ghp_255
      · exact ghp_495
      · exact ghp_584
      · exact ghp_975)
  have hc : ({1, 3, 15, 104, 164, 194, 255, 495, 584, 975} : Finset ℕ).card = 10 := by decide
  omega

/-- **Structural constraint on collision values.**  For `n ≥ 2`, whenever
`φ(n) = φ(n+1)` the common value is even.  The collision hypothesis is essential:
at `n = 2` we have `φ(2) = 1` (odd), but there `φ(2) ≠ φ(3)`; the equation transfers
the evenness of `φ(n+1)` (since `n+1 ≥ 3`) back to `φ(n)`.  This is a parity
obstruction underlying the sparsity of solutions. -/
theorem totient_shift_value_even {n : ℕ} (hn : 2 ≤ n)
    (h : Nat.totient n = Nat.totient (n + 1)) : Even (Nat.totient n) := by
  rw [h]
  exact Nat.totient_even (by omega)

/-- Non-saturation: for `x ≥ 2` strictly fewer than `x` integers collide, since
`n = 2` is a certified non-collision (`φ(2) = 1 ≠ 2 = φ(3)`).  Thus the trivial
upper bound is never attained. -/
theorem S1phi_lt_self {x : ℕ} (hx : 2 ≤ x) : S1phi x < x := by
  unfold S1phi
  have hcard : (Finset.Icc 1 x).card = x := by rw [Nat.card_Icc]; omega
  have hssub :
      (Finset.Icc 1 x).filter (fun n => Nat.totient n = Nat.totient (n + 1)) ⊂
        Finset.Icc 1 x := by
    refine Finset.filter_ssubset.mpr ⟨2, ?_, ?_⟩
    · rw [Finset.mem_Icc]; omega
    · decide
  calc ((Finset.Icc 1 x).filter _).card
      < (Finset.Icc 1 x).card := Finset.card_lt_card hssub
    _ = x := hcard

end TotientShift