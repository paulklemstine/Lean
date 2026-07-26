/-
# Symmetric-Key Cryptanalysis I: Differential Properties of S-boxes

This file formalizes the **difference distribution table (DDT)** of an S-box and
proves the fundamental *tight lower bound on the differential uniformity* of any
vectorial Boolean function. These are the building blocks of differential
cryptanalysis (Biham–Shamir): an attacker exploits input differences `a` that
propagate to output differences `b` with high probability `DDT(a,b) / |G|`.

We work over an elementary abelian 2-group `G` (the input space, characteristic
two: `x + x = 0`) mapping into a characteristic-two group `H` (the output space).
This is exactly the setting of an S-box `F : 𝔽₂ⁿ → 𝔽₂ᵐ`.

## Main results

* `ddt_even`     : every DDT entry `DDT(a,b)` with `a ≠ 0` is **even** — the
  classical pairing fact (`x` and `x + a` always solve together).
* `ddt_row_sum`  : each row of the DDT sums to `|G|`.
* `diff_uniformity_ge_two` : for every nonzero input difference `a` there is an
  output difference `b` with `DDT(a,b) ≥ 2`. Hence the **differential uniformity
  of any S-box is at least 2**, the bound met exactly by APN functions.
* `dp_ge_two_over_card` : the maximal differential probability of any S-box is at
  least `2 / |G|`. This is the *tight upper bound on differential security*: no
  S-box can do better than `2/|G|`, and APN permutations (e.g. the AES inversion
  S-box has uniformity 4, giving max DP `4/256 = 2⁻⁶`) approach it.

## Application Keywords

differential cryptanalysis, S-box, difference distribution table, DDT,
differential uniformity, APN function, almost perfect nonlinear, AES S-box,
maximum differential probability, wide-trail strategy, Biham-Shamir
-/

import Mathlib

open Finset

namespace SBoxDifferential

variable {G H : Type*} [Fintype G] [AddCommGroup G] [DecidableEq H] [AddCommGroup H]

/-- The difference distribution table entry of an S-box `F`: the number of inputs
`x` for which the input difference `a` propagates to the output difference `b`.
In characteristic two `F (x + a) + F x` is the output difference at `x`. -/
def ddt (F : G → H) (a : G) (b : H) : ℕ :=
  (Finset.univ.filter (fun x => F (x + a) + F x = b)).card

/-- Each row of the DDT (fixed input difference `a`) sums to `|G|`: every input
contributes to exactly one output difference. -/
theorem ddt_row_sum [Fintype H] (F : G → H) (a : G) :
    ∑ b : H, ddt F a b = Fintype.card G := by
  rw [Fintype.card]
  rw [Finset.card_eq_sum_card_fiberwise (f := fun x => F (x + a) + F x)
      (t := (univ : Finset H)) (by intro x _; exact mem_univ _)]
  rfl

/-- **Evenness of DDT entries.** For a nonzero input difference `a`, every DDT
entry `DDT(a,b)` is even. The witness set is invariant under the fixed-point-free
involution `x ↦ x + a` (using `a + a = 0`), so its cardinality is even. This is
the structural reason differential uniformity is always even. -/
theorem ddt_even (F : G → H) (a : G) (b : H) (ha : a ≠ 0) (hchar : ∀ x : G, x + x = 0) :
    Even (ddt F a b) := by
  have haa : a + a = 0 := hchar a
  unfold ddt
  set S := Finset.univ.filter (fun x => F (x + a) + F x = b) with hSdef
  have key : (S.card : ZMod 2) = 0 := by
    have hsum : ∑ _x ∈ S, (1 : ZMod 2) = 0 := by
      apply Finset.sum_involution (fun x _ => x + a)
      · intro x _; decide
      · intro x _ _ hcon
        exact ha (by
          have := add_left_cancel (a := x) (show x + a = x + 0 by simpa using hcon)
          simpa using this)
      · intro x hx
        simp only [hSdef, mem_filter, mem_univ, true_and] at hx ⊢
        have e : x + a + a = x := by rw [add_assoc, haa, add_zero]
        rw [e, add_comm]; exact hx
      · intro x _
        show x + a + a = x
        rw [add_assoc, haa, add_zero]
    simpa using hsum
  exact ZMod.natCast_eq_zero_iff_even.mp key

/-- **Differential uniformity is at least two.** For every nonzero input
difference `a` of any S-box there is an output difference `b` whose DDT entry is
at least `2`. Combined with `ddt_even`, this says the maximal DDT entry over
nonzero differences (the *differential uniformity*) is `≥ 2`, the value met
exactly by Almost Perfect Nonlinear (APN) functions. -/
theorem diff_uniformity_ge_two [Fintype H] (F : G → H) (a : G) (ha : a ≠ 0)
    (hchar : ∀ x : G, x + x = 0) (hG : 0 < Fintype.card G) :
    ∃ b : H, 2 ≤ ddt F a b := by
  by_contra h
  push_neg at h
  have hle : ∀ b : H, ddt F a b = 0 := by
    intro b
    have hb := h b
    rcases (ddt_even F a b ha hchar) with ⟨k, hk⟩
    omega
  have hsum := ddt_row_sum F a
  rw [Finset.sum_congr rfl (fun b _ => hle b)] at hsum
  simp only [Finset.sum_const_zero] at hsum
  omega

/-- The differential probability of `(a,b)` for the S-box `F`: the fraction of
inputs realizing the differential. -/
noncomputable def dp (F : G → H) (a : G) (b : H) : ℚ :=
  (ddt F a b : ℚ) / (Fintype.card G : ℚ)

/-- **Tight lower bound on the maximal differential probability.** For every
nonzero input difference there is an output difference whose differential
probability is at least `2 / |G|`. Hence no S-box achieves maximal differential
probability below `2/|G|`; APN functions attain this optimum. -/
theorem dp_ge_two_over_card [Fintype H] (F : G → H) (a : G) (ha : a ≠ 0)
    (hchar : ∀ x : G, x + x = 0) (hG : 0 < Fintype.card G) :
    ∃ b : H, (2 : ℚ) / (Fintype.card G : ℚ) ≤ dp F a b := by
  obtain ⟨b, hb⟩ := diff_uniformity_ge_two F a ha hchar hG
  refine ⟨b, ?_⟩
  unfold dp
  have h2 : (2 : ℚ) ≤ (ddt F a b : ℚ) := by exact_mod_cast hb
  gcongr

/-- For the trivial input difference `a = 0` the only realizable output difference
is `0` (with multiplicity `|G|`): in characteristic two `F x + F x = 0`. This
isolates the diagonal and is why differential cryptanalysis only considers
`a ≠ 0`. -/
theorem ddt_zero_input (F : G → H) (b : H) (hcharH : ∀ y : H, y + y = 0) :
    ddt F 0 b = if b = 0 then Fintype.card G else 0 := by
  unfold ddt
  split
  · next hb =>
    subst hb
    rw [Fintype.card]
    congr 1
    apply Finset.filter_true_of_mem
    intro x _
    simpa using hcharH (F x)
  · next hb =>
    apply Finset.card_eq_zero.mpr
    rw [Finset.filter_eq_empty_iff]
    intro x _
    simpa [hcharH (F x)] using fun h => hb h.symm

/-
-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer):
  H1 (bold): Every S-box has a nontrivial differential with probability ≥ 2/|G|;
     i.e. "perfect" differential resistance (max DP = 1/|G|) is impossible.
  H2: DDT entries are always even, forcing differential uniformity to be even.
  H3: The diagonal a=0 carries no cryptanalytic information.

EXPERIMENT (Experimenter):
  - Proved H2 (`ddt_even`) via the fixed-point-free involution x ↦ x+a, summing
    the indicator over ZMod 2 with `Finset.sum_involution`.
  - Proved row-sum = |G| (`ddt_row_sum`) by fiberwise counting.
  - Combined to get H1: if every row entry were < 2 then by evenness all are 0,
    contradicting the row sum |G| > 0.

ANALYSIS (Analyst):
  - SURVIVED: H1, H2, H3 all formalized with 0 sorries.
  - The evenness is the *only* obstruction needed; the rest is a counting
    pigeonhole. This unifies "DDT even" and "uniformity ≥ 2" into one argument.
  - Needed characteristic two on BOTH input (G) and output (H). On the output
    side it is needed only for `ddt_zero_input`; the differential bounds need it
    just on G (the involution lives in the input space).

CRITIQUE (Critic):
  - Not trivial: uses an involution/parity argument + counting, not `decide`.
  - The bound 2/|G| is TIGHT: APN functions (which exist for many n) achieve
    differential uniformity exactly 2. The AES inversion S-box over GF(2^8) has
    uniformity 4, giving max DP 4/256 = 2^{-6}; our bound 2/256 = 2^{-7} is the
    universal floor. We did not formalize the GF(2^8)-specific value 4 (that
    requires the explicit field arithmetic of the AES S-box) and flag it as a
    future direction.

SYNTHESIS (PI):
  The differential-uniformity floor `δ(F) ≥ 2` is the quantitative reason a
  single S-box cannot be made differentially trivial; the wide-trail strategy
  (next file) compensates by forcing *many* active S-boxes per trail.
-/

end SBoxDifferential