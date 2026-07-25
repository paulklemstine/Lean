/-
# Full tameness of the automorphism order on the superspecial K3 (synthesis)

This file is the **synthesis** of the symplectic/non-symplectic dichotomy (`SuperspecialK3Symplectic`)
and the Mukai arithmetic (`MukaiTameness`).  It records the foundational *tameness* fact on which the
Ohashi–Schütt analysis of the superspecial K3 surface in characteristic `p > 11` rests:

> if the symplectic part `G_s = ker χ` is one of the `11` Mukai maximal symplectic groups and the
> base field has characteristic `p > 11`, then the **entire** finite automorphism group `G` has order
> prime to `p`.

The proof factors `#G = #G_s · [G : G_s]` (`card_eq_symplectic_mul_index`) and shows `p` divides
neither factor: `p ∤ #G_s` by the Mukai arithmetic (`MukaiTameness.mukaiOrder_tame`), and `p ∤ [G:G_s]`
by the characteristic-`p` obstruction (`nonSymplecticIndex_not_dvd_char`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the two independent tameness facts — Mukai-order tameness of the symplectic
part and characteristic-`p` tameness of the non-symplectic index — should combine multiplicatively into
*global* tameness of `Aut(X)`, the standing assumption in the large-`p` classification.

Experiment (Experimenter): use `Nat.Prime.dvd_mul` to split `p ∣ #G_s · n` into `p ∣ #G_s ∨ p ∣ n`,
each refuted by an imported lemma.  `card_eq_symplectic_mul_index` supplies the factorisation of `#G`.

Analysis (Analyst): the result is genuinely a *bridge* — it cannot be proved from either file alone,
and both the algebraic (`sub_pow_char`) and arithmetic (`lcm = 40320`) inputs are load-bearing.  It
isolates exactly the hypothesis "(p>11)" needed; the remaining geometric rigidity (`n = 1`) is orthogonal
and tame-independent.

Critique (Critic): not trivial — it consumes two non-trivial theorems and the multiplicative splitting
of divisibility by a prime.  No vacuity: the hypothesis `Nat.card G_s ∈ mukaiOrders` is realizable (the
Mukai groups act), and the conclusion is a strict non-divisibility.

Synthesis (PI): global tameness of `#Aut(X)` for `p > 11` is now a theorem in this model, anchoring the
classification's standing hypothesis and setting up the future-direction conjecture that, additionally,
`[G : G_s] = 1`.
-/
import Catalog.Novelty.SuperspecialK3Symplectic
import Catalog.Novelty.MukaiTameness

namespace SuperspecialK3Symplectic

open MukaiTameness

variable {G : Type*} [Group G] [Finite G] {k : Type*} [Field k]

/-
**Global tameness of the automorphism order.**  For a base field of characteristic `p > 11`,
if the symplectic subgroup `G_s = ker χ` is a Mukai maximal symplectic group (its order lies in
`mukaiOrders`), then the order of the whole automorphism group `G` is prime to `p`.
-/
theorem aut_order_not_dvd_char (p : ℕ) [Fact p.Prime] [CharP k p] (hp11 : 11 < p)
    (χ : G →* kˣ) (hMukai : Nat.card (symplecticSubgroup χ) ∈ mukaiOrders) :
    ¬ p ∣ Nat.card G := by
  exact fun h => nonSymplecticIndex_not_dvd_char p χ <| Nat.Prime.dvd_mul ( Fact.out ) |>.1 ( by rw [ ← card_eq_symplectic_mul_index χ ] at h; exact h ) |>.resolve_left <| mukaiOrder_tame p ( Fact.out ) hp11 _ hMukai

/-
The order of `Aut(X)` is coprime to `p` under the same hypotheses.
-/
theorem aut_order_coprime_char (p : ℕ) [Fact p.Prime] [CharP k p] (hp11 : 11 < p)
    (χ : G →* kˣ) (hMukai : Nat.card (symplecticSubgroup χ) ∈ mukaiOrders) :
    Nat.Coprime p (Nat.card G) := by
  refine' ( Nat.Prime.coprime_iff_not_dvd ( Fact.out : p.Prime ) ).mpr _;
  convert aut_order_not_dvd_char p hp11 χ hMukai

end SuperspecialK3Symplectic