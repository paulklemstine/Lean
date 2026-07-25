/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Probability.CouponSiblingUniformExtremality

/-!
# Siblings of the Coupon Collector: the general-`N` closed form

This file records the exact closed form of the expected number of empty slots
`E_p[U_j^N]` for the sibling coupon-collector model of
`CouponSiblingUniformExtremality`, valid for every number of types `N` and every
sibling index `j ≥ 2`.

## Derivation of the closed form

Let `T` be the main collector's completion time and `N_i(T)` the number of copies
of type `i` seen by time `T`.  A slot for type `i` in sibling `j`'s album is empty
iff `N_i(T) < j`.  The event `{N_i(T) < j}` says that the `j`-th copy of type `i`
appears only *after* every other type has appeared at least once — equivalently,
every other type appears before the `j`-th draw of type `i`.  Inclusion–exclusion
over the set `S` of "still-missing" competitors gives

  `P(N_i(T) < j) = ∑_{S ⊆ [N]∖{i}} (-1)^{|S|} (p_i / (p_i + ∑_{s ∈ S} p_s))^j`,

because, restricted to draws whose type lies in `{i} ∪ S`, the first `j` draws are
all of type `i` with probability `(p_i/(p_i + q_S))^j`.  Summing over `i`,

  `E_p[U_j^N] = ∑_i ∑_{S ⊆ [N]∖{i}} (-1)^{|S|} (p_i / (p_i + ∑_{s ∈ S} p_s))^j`.

This is `EUgen` below.

## Results

* `EUgen_perm` — `E_p[U_j^N]` is invariant under permuting the coordinates of `p`;
  this **symmetry** is the structural prerequisite for the Schur-concavity claim.
* `EUgen_uniform` — the value at the uniform distribution `p ≡ 1/N`,
  `E_uniform[U_j^N] = N · ∑_{s < N} (-1)^s C(N-1, s) / (1+s)^j`.
* `EUgen_two` and `EUgen_eq_EU` — for `N = 2` the closed form collapses to
  `2 - p₀^j - p₁^j`, matching the fully-probabilistic two-type expectation `EU`
  proved in `CouponSiblingUniformExtremality`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the two-type closed form `2 - a^j - (1-a)^j` is the
shadow of a general-`N` inclusion–exclusion identity, and uniform extremality
should persist for all `N`.

Experiment (Experimenter): derived `EUgen` by inclusion–exclusion over the
"which competitors are still missing at the `j`-th copy of `i`" events.  Verified
numerically (rational arithmetic) that, e.g., `EUgen` at `N = 3, j = 3` gives
`85/36` at the uniform point and strictly less at `(1/2,1/4,1/4)`, `(3/5,1/5,1/5)`,
`(4/5,1/10,1/10)` — consistent with uniform being the strict maximiser.

Analysis (Analyst): the object is a genuinely symmetric function of `p`
(`EUgen_perm`), has the clean uniform value `N·∑_s (-1)^s C(N-1,s)/(1+s)^j`, and
degenerates to the proven two-type formula.  The alternating structure obstructs a
short Schur-concavity proof; the two-point transfer inequality is the missing
ingredient (see `FUTURE_DIRECTIONS`).

Critique (Critic): symmetry is unconditional (no positivity needed — vanishing
denominators just yield `0` and permute along), while the numeric value and the
two-type collapse use `0 < p_i`.  No result is vacuous: `EUgen_perm` moves a real
alternating powerset sum, and `EUgen_eq_EU` ties the algebra to the honest `tsum`
expectation of the companion file.

Synthesis (PI): the general-`N` skeleton (symmetry + uniform value + two-type
bridge) is in place; global Schur-concavity is promoted to a headline conjecture.
-- !-- end Lab Notes -- !--
-/

namespace CouponSibling

open scoped BigOperators
open Finset

variable {N : ℕ}

/-- The general-`N` closed form for the expected number of empty slots
`E_p[U_j^N]`, obtained by inclusion–exclusion. -/
noncomputable def EUgen (p : Fin N → ℝ) (j : ℕ) : ℝ :=
  ∑ i, ∑ S ∈ (Finset.univ.erase i).powerset,
    (-1) ^ S.card * (p i / (p i + ∑ s ∈ S, p s)) ^ j

/-
**Permutation symmetry.** `E_p[U_j^N]` depends on `p` only through its
multiset of values: it is invariant under permuting coordinates.
-/
theorem EUgen_perm (p : Fin N → ℝ) (j : ℕ) (σ : Equiv.Perm (Fin N)) :
    EUgen (p ∘ σ) j = EUgen p j := by
  convert Finset.sum_bij ( fun i _ => σ i ) _ _ _ _ using 1;
  · exact fun _ _ => Finset.mem_univ _;
  · aesop;
  · exact fun b _ => ⟨ σ.symm b, Finset.mem_univ _, by simp +decide ⟩;
  · intro a ha; refine' Finset.sum_bij ( fun S _ => S.image σ ) _ _ _ _ <;> simp +decide [ Finset.card_image_of_injective, Equiv.injective ] ;
    · simp +contextual [ Finset.subset_iff ];
    · intro s₁ hs₁ s₂ hs₂ h; rw [ Finset.image_injective ( σ.injective ) h ] ;
    · intro b hb; use Finset.image ( σ.symm ) b; simp_all +decide [ Finset.subset_iff ] ;
      simp_all +decide [ Finset.ext_iff, Equiv.symm_apply_eq ];
      exact fun x => ⟨ fun ⟨ y, hy, hy' ⟩ => hy'.symm ▸ hy, fun hx => ⟨ σ.symm x, by simpa using hx, by simp +decide ⟩ ⟩

/-
**Value at the uniform distribution.**
-/
theorem EUgen_uniform (hN : 0 < N) (j : ℕ) :
    EUgen (fun _ : Fin N => (1 : ℝ) / N) j
      = (N : ℝ) * ∑ s ∈ Finset.range N,
          (-1 : ℝ) ^ s * (Nat.choose (N - 1) s : ℝ) / (1 + (s : ℝ)) ^ j := by
  unfold EUgen; simp +decide ;
  -- Simplify the inner sum using the binomial theorem.
  have h_inner : ∀ i : Fin N, ∑ S ∈ (Finset.univ.erase i).powerset, (-1 : ℝ) ^ S.card * ((1 : ℝ) / (1 + S.card)) ^ j = ∑ s ∈ Finset.range N, (-1 : ℝ) ^ s * (Nat.choose (N - 1) s : ℝ) / (1 + s) ^ j := by
    intro i;
    rw [ Finset.sum_powerset ];
    simp +decide [ div_eq_mul_inv ];
    rw [ Nat.sub_add_cancel hN ];
    exact Finset.sum_congr rfl fun x hx => by rw [ Finset.sum_congr rfl fun y hy => by rw [ Finset.mem_powersetCard.mp hy |>.2 ] ] ; simp +decide [ mul_comm, mul_left_comm, Finset.card_univ, Finset.card_erase_of_mem ( Finset.mem_univ i ) ] ;
  convert Finset.sum_congr rfl fun i hi => h_inner i using 2;
  · field_simp;
  · norm_num [ Finset.mul_sum _ _ _ ]

/-
**Two-type collapse.** For `N = 2`, the closed form is `2 - p₀^j - p₁^j`.
-/
theorem EUgen_two (p : Fin 2 → ℝ) (h0 : 0 < p 0) (h1 : 0 < p 1)
    (hsum : p 0 + p 1 = 1) (j : ℕ) :
    EUgen p j = 2 - (p 0) ^ j - (p 1) ^ j := by
  unfold EUgen; simp +decide [ *, Fin.sum_univ_two ] ; ring;
  rw [ show ( univ.erase 0 : Finset ( Fin 2 ) ) = { 1 } by decide, show ( univ.erase 1 : Finset ( Fin 2 ) ) = { 0 } by decide ] ; norm_num ; ring;
  rw [ show ( { 1 } : Finset ( Fin 2 ) ).powerset = { ∅, { 1 } } by decide, show ( { 0 } : Finset ( Fin 2 ) ).powerset = { ∅, { 0 } } by decide ] ; norm_num ; ring;
  norm_num [ hsum, h0.ne', h1.ne' ] ; ring

/-
**Bridge to the fully-probabilistic two-type expectation.** For `a ∈ (0,1)`
and the two-type vector `(a, 1-a)`, the general closed form agrees with the
`tsum`-defined expectation `EU a j` of `CouponSiblingUniformExtremality`.
-/
theorem EUgen_eq_EU {a : ℝ} (h0 : 0 < a) (h1 : a < 1) {j : ℕ} (hj : 2 ≤ j) :
    EUgen (fun k : Fin 2 => if k = 0 then a else 1 - a) j = EU a j := by
  rw [ EUgen_two, EU_eq h0 h1 hj ];
  · rfl;
  · grind;
  · exact sub_pos_of_lt h1;
  · norm_num

end CouponSibling