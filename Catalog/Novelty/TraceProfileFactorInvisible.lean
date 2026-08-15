/-
# TRACEPROFILE III — factor invisible, trace visible: the exact information contrast

Phase A research file (Novelty domain), Paper 50 / Experiment 385.

The experiment measured, for semiprimes `N = p q` and moduli `m`,

* `I(p mod m ; N mod m) ≈ 0` for **every** `m` (the "zero block"), against
* `I(s mod m ; N mod m) ≈ 1` bit for every odd prime `m`, where `s = p + q`.

This file proves the exact combinatorial content of both halves over a prime
field `F_q`, in the counting form of mutual information (a random variable pair is
information-free exactly when its joint counts factor as a product).

## Main results

* `card_factorSet_prime` — **factor invisibility**: the set of residues a factor of
  a nonzero `N` can occupy is *all* of `F_q^×`; the residue of `N` excludes no
  candidate factor residue.  Zero bits.
* `card_fiber_cofactor` — each candidate factor residue has exactly one completion.
* `factor_indep_of_product` — **`I(p mod q ; N mod q) = 0` exactly**: over the
  uniform model on pairs of units, the events `{x = a}` and `{x y = b}` satisfy the
  product rule for all `a`, `b`.
* `trace_not_indep_of_product` — **the trace is different**: the analogous product
  rule *fails* for the trace at `q = 5`, so `I(s mod q ; N mod q) > 0`.
* `traceSet_card_lt_factorSet_card` — the quantitative contrast: for `q ≥ 5` the
  trace is confined to strictly fewer residues than the factor, `≈ q/2` versus
  `q - 1`.
* `trace_bit_versus_factor_bits` — one bit for the trace, zero for the factor,
  in the same normalisation: `2 * |traceSet| ≤ |factorSet| + 2 = q + 1`.
-/

import Mathlib
import Novelty.TraceProfileTraceSet

namespace Novelty.TraceProfile

open Finset

/-- The set of residues that a *factor* of `N` can occupy. -/
def factorSet {R : Type*} [CommRing R] [Fintype R] [DecidableEq R] (N : R) : Finset R :=
  (factorPairs N).image (fun z => z.1)

@[simp] theorem mem_factorSet {R : Type*} [CommRing R] [Fintype R] [DecidableEq R]
    {N x : R} : x ∈ factorSet N ↔ ∃ y : R, x * y = N := by
  simp [factorSet, factorPairs, Prod.exists]

section Prime

variable {q : ℕ} [hq : Fact (Nat.Prime q)]

/-- **Factor invisibility.**  Over a prime field every nonzero residue occurs as the
residue of a factor of any nonzero `N`: the public residue `N mod q` rules out no
candidate.  The factor residue set has `q - 1` elements — the full unit group. -/
theorem card_factorSet_prime (N : ZMod q) (hN : N ≠ 0) :
    factorSet N = univ.filter (fun x : ZMod q => x ≠ 0) ∧ (factorSet N).card = q - 1 := by
  have hset : factorSet N = univ.filter (fun x : ZMod q => x ≠ 0) := by
    ext x
    simp only [mem_factorSet, mem_filter, mem_univ, true_and]
    constructor
    · rintro ⟨y, hxy⟩
      rintro rfl
      rw [zero_mul] at hxy
      exact hN hxy.symm
    · intro hx
      exact ⟨N * x⁻¹, by field_simp⟩
  refine ⟨hset, ?_⟩
  rw [hset]
  have hAe : (univ.filter (fun x : ZMod q => x ≠ 0)) = univ.erase (0 : ZMod q) := by
    ext x; simp [Finset.mem_erase]
  rw [hAe, Finset.card_erase_of_mem (mem_univ 0), Finset.card_univ, ZMod.card]

/-- Every candidate factor residue has exactly one cofactor: the conditional
distribution of `N mod q` given `p mod q` is uniform on the units. -/
theorem card_fiber_cofactor (a b : ZMod q) (ha : a ≠ 0) :
    (univ.filter (fun y : ZMod q => a * y = b)).card = 1 := by
  rw [Finset.card_eq_one]
  refine ⟨a⁻¹ * b, ?_⟩
  ext y
  simp only [mem_filter, mem_univ, true_and, mem_singleton]
  constructor
  · rintro rfl
    field_simp
  · rintro rfl
    field_simp

/-- The uniform sample space of the experiment: ordered pairs of nonzero residues
(the residues of the two prime factors). -/
def unitPairs (q : ℕ) [NeZero q] : Finset (ZMod q × ZMod q) :=
  univ.filter (fun z => z.1 ≠ 0 ∧ z.2 ≠ 0)

theorem card_unitPairs : (unitPairs q).card = (q - 1) * (q - 1) := by
  have h : unitPairs q
      = (univ.filter (fun x : ZMod q => x ≠ 0)) ×ˢ (univ.filter (fun x : ZMod q => x ≠ 0)) := by
    ext z; simp [unitPairs, mem_product]
  have hA : (univ.filter (fun x : ZMod q => x ≠ 0)).card = q - 1 := by
    have hAe : (univ.filter (fun x : ZMod q => x ≠ 0)) = univ.erase (0 : ZMod q) := by
      ext x; simp [Finset.mem_erase]
    rw [hAe, Finset.card_erase_of_mem (mem_univ 0), Finset.card_univ, ZMod.card]
  rw [h, Finset.card_product, hA]

/-- **`I(p mod q ; N mod q) = 0`, exactly.**  On the uniform model over pairs of
nonzero residues, the factor value `x` and the product `x*y` are statistically
independent: joint counts factor as a product of marginals, for every pair of
values.  No congruence observation of `N` carries any information about `p mod q`. -/
theorem factor_indep_of_product (a b : ZMod q) (ha : a ≠ 0) (hb : b ≠ 0) :
    ((unitPairs q).filter (fun z => z.1 = a ∧ z.1 * z.2 = b)).card * (unitPairs q).card
      = ((unitPairs q).filter (fun z => z.1 = a)).card
        * ((unitPairs q).filter (fun z => z.1 * z.2 = b)).card := by
  have hA : (univ.filter (fun x : ZMod q => x ≠ 0)).card = q - 1 := by
    have hAe : (univ.filter (fun x : ZMod q => x ≠ 0)) = univ.erase (0 : ZMod q) := by
      ext x; simp [Finset.mem_erase]
    rw [hAe, Finset.card_erase_of_mem (mem_univ 0), Finset.card_univ, ZMod.card]
  -- the joint event is a single point
  have hjoint : ((unitPairs q).filter (fun z => z.1 = a ∧ z.1 * z.2 = b)).card = 1 := by
    rw [Finset.card_eq_one]
    refine ⟨(a, a⁻¹ * b), ?_⟩
    ext ⟨z1, z2⟩
    simp only [unitPairs, Finset.filter_filter, mem_filter, mem_univ, true_and, mem_singleton,
      Prod.mk.injEq]
    constructor
    · rintro ⟨⟨-, hz2⟩, rfl, hprod⟩
      refine ⟨rfl, ?_⟩
      field_simp
      linear_combination hprod
    · rintro ⟨rfl, rfl⟩
      exact ⟨⟨ha, mul_ne_zero (inv_ne_zero ha) hb⟩, rfl, by field_simp⟩
  -- the marginal in the factor
  have hmarg1 : ((unitPairs q).filter (fun z => z.1 = a)).card = q - 1 := by
    have : ((unitPairs q).filter (fun z => z.1 = a))
        = ({a} : Finset (ZMod q)) ×ˢ (univ.filter (fun x : ZMod q => x ≠ 0)) := by
      ext z
      simp only [unitPairs, Finset.filter_filter, mem_filter, mem_univ, true_and, mem_product,
        mem_singleton]
      constructor
      · rintro ⟨⟨-, hz2⟩, rfl⟩; exact ⟨rfl, hz2⟩
      · rintro ⟨rfl, hz2⟩; exact ⟨⟨ha, hz2⟩, rfl⟩
    rw [this, Finset.card_product, Finset.card_singleton, hA, one_mul]
  -- the marginal in the product
  have hmarg2 : ((unitPairs q).filter (fun z => z.1 * z.2 = b)).card = q - 1 := by
    have himg : ((unitPairs q).filter (fun z => z.1 * z.2 = b))
        = (univ.filter (fun x : ZMod q => x ≠ 0)).image (fun x => (x, x⁻¹ * b)) := by
      ext ⟨z1, z2⟩
      simp only [unitPairs, Finset.filter_filter, mem_filter, mem_univ, true_and, mem_image,
        Prod.mk.injEq]
      constructor
      · rintro ⟨⟨hz1, hz2⟩, hprod⟩
        refine ⟨z1, hz1, rfl, ?_⟩
        field_simp
        linear_combination -hprod
      · rintro ⟨x, hx, rfl, rfl⟩
        refine ⟨⟨hx, mul_ne_zero (inv_ne_zero hx) hb⟩, ?_⟩
        field_simp
    rw [himg, Finset.card_image_of_injective, hA]
    intro x y hxy
    exact (Prod.ext_iff.1 hxy).1
  rw [hjoint, hmarg1, hmarg2, card_unitPairs, one_mul]

end Prime

/-- **The trace is *not* information-free.**  At `q = 5`, with trace value `s = 2`
and product value `b = 1`, the joint count violates the product rule
(`1 * 16 ≠ 3 * 4`).  Hence `I(s mod 5 ; N mod 5) > 0`: the trace is congruence
visible exactly where the factor is invisible. -/
theorem trace_not_indep_of_product :
    ((unitPairs 5).filter (fun z => z.1 + z.2 = 2 ∧ z.1 * z.2 = 1)).card * (unitPairs 5).card
      ≠ ((unitPairs 5).filter (fun z => z.1 + z.2 = 2)).card
        * ((unitPairs 5).filter (fun z => z.1 * z.2 = 1)).card := by
  decide

section Contrast

variable {q : ℕ} [hq : Fact (Nat.Prime q)]

/-- **The quantitative contrast, one inequality.**  `2 |traceSet| ≤ |factorSet| + 2`:
in the same normalisation the trace is pinned to half the residues (one bit) while
the factor set is the full unit group (zero bits). -/
theorem trace_bit_versus_factor_bits (hq2 : q ≠ 2) (N : ZMod q) (hN : N ≠ 0) :
    2 * (traceSet N).card ≤ (factorSet N).card + 2 := by
  have hf := (card_factorSet_prime N hN).2
  have ht := card_traceSet_prime hq2 N hN
  have hq2' : 2 ≤ q := hq.out.two_le
  by_cases hs : IsSquare N
  · rw [if_pos hs] at ht; omega
  · rw [if_neg hs] at ht; omega

/-- For `q ≥ 5` the trace really is more constrained than the factor. -/
theorem traceSet_card_lt_factorSet_card (hq5 : 5 ≤ q) (N : ZMod q) (hN : N ≠ 0) :
    (traceSet N).card < (factorSet N).card := by
  have hq2 : q ≠ 2 := by omega
  have hf := (card_factorSet_prime N hN).2
  have ht := card_traceSet_prime hq2 N hN
  by_cases hs : IsSquare N
  · rw [if_pos hs] at ht; omega
  · rw [if_neg hs] at ht; omega

end Contrast

end Novelty.TraceProfile