/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A finite-torus multiplier avoidance theorem

For a prime `p`, work over the finite field `F = ZMod p` and the finite torus
`F × F`.  Given a set `D` of nonzero displacement vectors with `D.card < p`, we
produce a single multiplier `a : F × F` that "avoids" every displacement, in the
sense that the dot product `d.1 * a.1 + d.2 * a.2` is nonzero for all `d ∈ D`.

The proof is a clean finite-cardinality counting argument (replacing earlier
circular/infinite lacunary reasoning):

* For each nonzero `d`, the "bad" set of multipliers killing `d` is a line in the
  torus, so it has at most `p` points (`bad_card_le`).
* The union of the `D.card` bad lines has fewer than `p * p` points, while the
  whole torus has exactly `p * p` points.  Hence some multiplier escapes every
  bad line.

## Main results

* `exists_good_multiplier_zmod` : the finite-torus multiplier avoidance theorem.
* `exists_good_multiplier_int` : an integer-displacement corollary, where each
  vector has a coordinate not divisible by `p`.
-/

import Mathlib

open Finset

namespace TorusMultiplierAvoidance

variable {p : ℕ} [Fact p.Prime]

/-- The set of multipliers `a` that "kill" the displacement `d`, i.e. for which
the dot product `d.1 * a.1 + d.2 * a.2` vanishes. -/
def bad (d : ZMod p × ZMod p) : Finset (ZMod p × ZMod p) :=
  Finset.univ.filter fun a => d.1 * a.1 + d.2 * a.2 = 0

/-
A nonzero displacement vector's bad set is a line: it has at most `p`
multipliers.
-/
lemma bad_card_le (d : ZMod p × ZMod p) (hd : d ≠ 0) :
    (bad d).card ≤ p := by
  by_cases h1 : d.1 = 0;
  · obtain ⟨a, ha⟩ : ∃ a : ZMod p, ∀ b : ZMod p × ZMod p, b ∈ bad d ↔ b.snd = a := by
      use 0; simp_all +decide [ bad ] ;
      exact fun b hb => False.elim <| hd <| Prod.ext h1 hb;
    rw [ show bad d = Finset.image ( fun x : ZMod p => ( x, a ) ) ( Finset.univ : Finset ( ZMod p ) ) by ext; aesop ] ; rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ] ;
  · convert Finset.card_le_card ( show bad d ⊆ Finset.image ( fun x : ZMod p => ( -d.2 * x / d.1, x ) ) ( Finset.univ : Finset ( ZMod p ) ) from ?_ ) using 2 ; simp +decide [ h1, Finset.card_image_of_injective, Function.Injective, Prod.ext_iff ];
    intro x hx; simp_all +decide [ bad ] ;
    exact ⟨ x.2, Prod.ext ( by rw [ div_eq_iff h1 ] ; linear_combination -hx ) rfl ⟩

/-
The finite-torus multiplier avoidance theorem: if `D` is a set of nonzero
displacement vectors over `ZMod p` with `D.card < p`, then some multiplier `a`
gives a nonzero dot product with every `d ∈ D`.
-/
theorem exists_good_multiplier_zmod
    (D : Finset (ZMod p × ZMod p))
    (hD : ∀ d ∈ D, d ≠ 0)
    (hcard : D.card < p) :
    ∃ a : ZMod p × ZMod p,
      ∀ d ∈ D, d.1 * a.1 + d.2 * a.2 ≠ 0 := by
  -- By `Finset.card_biUnion_le`, `BadUnion.card ≤ ∑ d ∈ D, (bad d).card`.
  have h_bad_union_card : (D.biUnion (fun d => bad d)).card ≤ D.card * p := by
    exact le_trans ( Finset.card_biUnion_le ) ( Finset.sum_le_card_nsmul _ _ _ fun x hx => bad_card_le x ( hD x hx ) );
  contrapose! h_bad_union_card;
  rw [ show ( D.biUnion fun d => bad d ) = Finset.univ from Finset.eq_univ_of_forall fun x => by obtain ⟨ d, hd₁, hd₂ ⟩ := h_bad_union_card x; exact Finset.mem_biUnion.mpr ⟨ d, hd₁, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hd₂ ⟩ ⟩ ] ; simp +decide [ Finset.card_univ ] ; nlinarith;

/-
Integer-displacement corollary.  If `E` is a set of integer displacement
vectors, each having at least one coordinate not divisible by `p`, and
`E.card < p`, then there is a multiplier `a : ZMod p × ZMod p` whose reduced dot
product with every `e ∈ E` is nonzero.  This connects the finite theorem to
lacunary-distance multiplier constructions.
-/
theorem exists_good_multiplier_int
    (E : Finset (ℤ × ℤ))
    (hE : ∀ e ∈ E, ¬ (p : ℤ) ∣ e.1 ∨ ¬ (p : ℤ) ∣ e.2)
    (hcard : E.card < p) :
    ∃ a : ZMod p × ZMod p,
      ∀ e ∈ E, (e.1 : ZMod p) * a.1 + (e.2 : ZMod p) * a.2 ≠ 0 := by
  -- Let's define the set $D$ of reduced displacement vectors.
  set D : Finset ((ZMod p) × (ZMod p)) := E.image (fun e => (e.1, e.2));
  -- Apply `exists_good_multiplier_zmod` to `D`:
  obtain ⟨a, ha⟩ : ∃ a : (ZMod p) × (ZMod p), ∀ d ∈ D, d.1 * a.1 + d.2 * a.2 ≠ 0 := by
    apply exists_good_multiplier_zmod;
    · simp +zetaDelta at *;
      intro a b x y hx hy hxy ha hb; specialize hE x y hx; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;
    · exact lt_of_le_of_lt ( Finset.card_image_le ) hcard;
  exact ⟨ a, fun e he => ha _ <| Finset.mem_image_of_mem _ he ⟩

end TorusMultiplierAvoidance