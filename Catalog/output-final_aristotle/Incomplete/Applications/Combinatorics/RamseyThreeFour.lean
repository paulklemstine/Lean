/-
# The exact Ramsey number `R(3,4) = 9`

Building on `Applications.Ramsey` (which develops the arrow relation `Arrows n s t`
and proves `R(3,3) = 6` together with the Erdős–Szekeres binomial bound), this
file pins down the next diagonal-adjacent value:

* `arrows_three_four`        : `Arrows 9 3 4`   (every 2-colouring of `K₉` has a
                                                 red triangle or a blue `K₄`)
* `not_arrows_eight_three_four` : `¬ Arrows 8 3 4` (the Möbius ladder `C₈(1,4)`
                                                 is a colouring of `K₈` with neither)
* `ramsey_three_four`        : `Arrows 9 3 4 ∧ ¬ Arrows 8 3 4`, i.e. `R(3,4) = 9`.

The Erdős–Szekeres binomial bound only gives `R(3,4) ≤ C(5,2) = 10`.  The sharp
value `9` requires the classical *parity refinement*: in a hypothetical
counterexample on `9` vertices, every vertex must have red-degree exactly `3`,
making the red graph `3`-regular on `9` vertices — impossible because the sum of
degrees `9·3 = 27` is odd while it must equal twice the number of red edges.

## Lab Notes — see `-- !-- Lab Notes -- !--` blocks below.
-/

import Mathlib
import Applications.Ramsey

open scoped Classical
open SimpleGraph Finset

namespace RamseyTheory

/- -- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): R(3,4) = 9.  Lower bound by an explicit 8-vertex
construction; upper bound R(3,4) ≤ 9 strictly improves the binomial bound 10 and
must therefore use an arithmetic (parity) obstruction rather than pure recursion.

EXPERIMENT (Experimenter): computational search confirmed the Möbius ladder
C₈(1,4) on ℤ/8 (difference set {±1, 4}) is triangle-free with K₄-free complement,
verified by `decide`.  For the upper bound, the degree-counting + handshake
parity argument was isolated into three reusable lemmas below.
-/

/-! ## Handshake parity for red degrees inside a finite set -/

/-
**Handshake parity.** For any colouring `G` and finite vertex set `W`, the total
red-degree `∑_{v ∈ W} (# red neighbours of v inside W)` is even, because it counts
ordered red pairs `(v, w)` inside `W`, and the swap `(v,w) ↦ (w,v)` is a
fixed-point-free involution on that set.
-/
lemma red_nbrs_sum_even {V : Type} [DecidableEq V] (G : SimpleGraph V) (W : Finset V) :
    Even (∑ v ∈ W, ((W.erase v).filter (fun w => G.Adj v w)).card) := by
  convert even_iff_two_dvd.mpr ( _ ) using 1;
  have h_even : Even (∑ v ∈ W, ∑ w ∈ W, if G.Adj v w then 1 else 0) := by
    have h_even : ∑ v ∈ W, ∑ w ∈ W, (if G.Adj v w then 1 else 0) = ∑ e ∈ Finset.filter (fun e => e ∈ G.edgeSet) (Finset.image (fun (e : V × V) => s(e.1, e.2)) (W ×ˢ W)), 2 := by
      have h_even : ∀ v ∈ W, ∑ w ∈ W, (if G.Adj v w then 1 else 0) = ∑ e ∈ Finset.filter (fun e => e ∈ G.edgeSet) (Finset.image (fun (e : V × V) => s(e.1, e.2)) (W ×ˢ W)), (if v ∈ e then 1 else 0) := by
        intro v hv
        simp [Finset.sum_ite];
        refine' Finset.card_bij ( fun x hx => Sym2.mk ( v, x ) ) _ _ _ <;> simp_all +decide [ SimpleGraph.adj_comm ];
        · exact fun a ha ha' => ⟨ v, a, ⟨ hv, ha ⟩, Or.inl ⟨ rfl, rfl ⟩ ⟩;
        · aesop;
        · rintro _ x y hx hy rfl hxy hv; cases hv; aesop;
      rw [ Finset.sum_congr rfl h_even, Finset.sum_comm ];
      refine' Finset.sum_congr rfl fun e he => _;
      rcases e with ⟨ x, y ⟩ ; simp_all +decide [ Finset.sum_ite ];
      rw [ show { x_1 ∈ W | x_1 = x ∨ x_1 = y } = { x, y } by ext; aesop ] ; rw [ Finset.card_insert_of_notMem, Finset.card_singleton ] ; aesop;
    simp_all +decide [ Finset.sum_ite ];
  convert even_iff_two_dvd.mp h_even using 1;
  simp +decide [ Finset.filter_erase, SimpleGraph.adj_comm ]

/-! ## Local degree obstructions -/

/-
If a vertex `v ∈ W` has at least `4` red neighbours inside `W`, then `W` already
contains a red triangle or a blue `K₄`.  (Among `4` red neighbours of `v`, either
two are red-adjacent — giving a red triangle with `v` — or all `6` pairs are blue,
giving a blue `K₄`.)
-/
lemma red_or_blue_of_four_red_nbrs {V : Type} [DecidableEq V] (G : SimpleGraph V)
    (W : Finset V) (v : V) (hv : v ∈ W)
    (h4 : 4 ≤ ((W.erase v).filter (fun w => G.Adj v w)).card) :
    (∃ S : Finset V, S ⊆ W ∧ G.IsNClique 3 S) ∨
    (∃ S : Finset V, S ⊆ W ∧ Gᶜ.IsNClique 4 S) := by
  -- Let R = (W.erase v).filter (fun w => G.Adj v w). From h4 : 4 ≤ R.card, obtain S ⊆ R with S.card = 4 using Finset.exists_subset_card_eq.
  obtain ⟨S, hS₁, hS₂⟩ : ∃ S ⊆ (W.erase v).filter (fun w => v ≠ w ∧ G.Adj v w), S.card = 4 := by
    have := Finset.exists_subset_card_eq h4;
    grind +qlia;
  by_cases h : ∃ a b : V, a ∈ S ∧ b ∈ S ∧ a ≠ b ∧ G.Adj a b <;> simp_all +decide [ Finset.subset_iff ];
  · obtain ⟨ a, ha, b, hb, hab, h ⟩ := h; use Or.inl ⟨ { v, a, b }, ?_, ?_ ⟩ <;> simp_all +decide [ SimpleGraph.isNClique_iff ] ;
  · refine Or.inr ⟨ S, ?_, ?_ ⟩ <;> simp_all +decide [ SimpleGraph.isNClique_iff, SimpleGraph.isNIndepSet_iff ];
    exact fun x hx y hy hxy => by specialize h x hx y hy hxy; aesop;

/-
If a vertex `v ∈ W` has at least `6` blue neighbours inside `W`, then `W` contains
a red triangle or a blue `K₄`.  (Apply `R(3,3) = 6` to the `6` blue neighbours: a
red triangle is done, while a blue triangle extends by `v` to a blue `K₄`.)
-/
lemma red_or_blue_of_six_blue_nbrs {V : Type} [DecidableEq V] (G : SimpleGraph V)
    (W : Finset V) (v : V) (hv : v ∈ W)
    (h6 : 6 ≤ ((W.erase v).filter (fun w => ¬ G.Adj v w)).card) :
    (∃ S : Finset V, S ⊆ W ∧ G.IsNClique 3 S) ∨
    (∃ S : Finset V, S ⊆ W ∧ Gᶜ.IsNClique 4 S) := by
  obtain ⟨ S, hS₁, hS₂ ⟩ := Finset.exists_subset_card_eq h6;
  obtain ⟨ S', hS' ⟩ := arrows_three_three G S ( by linarith );
  · grind;
  · obtain ⟨ S', hS' ⟩ := ‹_›;
    refine Or.inr ⟨ Insert.insert v S', ?_, ?_ ⟩ <;> simp_all +decide [ Finset.subset_iff, SimpleGraph.isNClique_iff ];
    simp_all +decide [ Set.Pairwise, Finset.card_insert_of_notMem ];
    exact ⟨ fun x hx => by have := hS₁ ( hS'.1 hx ) ; tauto, by rw [ Finset.card_insert_of_notMem ( fun hx => by have := hS₁ ( hS'.1 hx ) ; tauto ), hS'.2.2 ] ⟩

/-! ## Upper bound `R(3,4) ≤ 9` -/

/--
**Upper bound.** Every red/blue colouring of `K₉` contains a red triangle or a
blue `K₄`, i.e. `Arrows 9 3 4`.
-/
theorem arrows_three_four : Arrows 9 3 4 := by
  intro V hdec G W hW
  by_contra hcon
  rw [not_or] at hcon
  obtain ⟨hno_red, hno_blue⟩ := hcon
  -- Reduce to an exact 9-element subset.
  obtain ⟨W9, hsub, hcard9⟩ := Finset.exists_subset_card_eq hW
  -- No clique lives inside `W9` (else it lives inside `W`).
  have hno_red' : ¬ ∃ S : Finset V, S ⊆ W9 ∧ G.IsNClique 3 S := by
    rintro ⟨S, hS, hSc⟩; exact hno_red ⟨S, hS.trans hsub, hSc⟩
  have hno_blue' : ¬ ∃ S : Finset V, S ⊆ W9 ∧ Gᶜ.IsNClique 4 S := by
    rintro ⟨S, hS, hSc⟩; exact hno_blue ⟨S, hS.trans hsub, hSc⟩
  -- Each vertex of `W9` has red-degree exactly 3.
  set f : V → ℕ := fun v => ((W9.erase v).filter (fun w => G.Adj v w)).card with hf
  have hdeg3 : ∀ v ∈ W9, f v = 3 := by
    intro v hv
    set r := ((W9.erase v).filter (fun w => G.Adj v w)).card with hr
    set b := ((W9.erase v).filter (fun w => ¬ G.Adj v w)).card with hb
    have hsum : r + b = 8 := by
      rw [hr, hb, Finset.card_filter_add_card_filter_not,
        Finset.card_erase_of_mem hv, hcard9]
    have hrle : r ≤ 3 := by
      by_contra h
      push_neg at h
      rcases red_or_blue_of_four_red_nbrs G W9 v hv (by omega) with h' | h'
      · exact hno_red' h'
      · exact hno_blue' h'
    have hble : b ≤ 5 := by
      by_contra h
      push_neg at h
      rcases red_or_blue_of_six_blue_nbrs G W9 v hv (by omega) with h' | h'
      · exact hno_red' h'
      · exact hno_blue' h'
    show r = 3
    omega
  -- Handshake parity: total red-degree is even, but equals 27.
  have heven : Even (∑ v ∈ W9, f v) := red_nbrs_sum_even G W9
  have hsum27 : (∑ v ∈ W9, f v) = 27 := by
    rw [Finset.sum_congr rfl hdeg3, Finset.sum_const, hcard9]; norm_num
  rw [hsum27] at heven
  exact (by decide : ¬ Even 27) heven

/-! ## Lower bound `R(3,4) > 8` via the Möbius ladder `C₈(1,4)` -/

/-- The Möbius ladder `C₈(1,4)` on `ℤ/8`: vertices `a, b` are red-adjacent iff
their difference is `±1` or `4`.  This is the unique extremal colouring of `K₈`
witnessing `R(3,4) > 8`. -/
def graph34 : SimpleGraph (Fin 8) := SimpleGraph.fromRel (fun a b => (a - b = 1) ∨ (a - b = 4))

instance : DecidableRel graph34.Adj := by unfold graph34; infer_instance

set_option maxRecDepth 10000 in
/-- The Möbius ladder has no red triangle. -/
theorem graph34_no_red_triangle : ¬ ∃ S : Finset (Fin 8), graph34.IsNClique 3 S := by
  decide

set_option maxRecDepth 10000 in
/-- The complement of the Möbius ladder has no blue `K₄`. -/
theorem graph34_no_blue_K4 : ¬ ∃ S : Finset (Fin 8), graph34ᶜ.IsNClique 4 S := by
  decide

/-- **Lower bound.** The Möbius-ladder colouring of `K₈` has neither a red
triangle nor a blue `K₄`, so `¬ Arrows 8 3 4`, i.e. `R(3,4) > 8`. -/
theorem not_arrows_eight_three_four : ¬ Arrows 8 3 4 := by
  intro h
  have := h graph34 Finset.univ (by simp)
  rcases this with ⟨S, _, hS⟩ | ⟨S, _, hS⟩
  · exact graph34_no_red_triangle ⟨S, hS⟩
  · exact graph34_no_blue_K4 ⟨S, hS⟩

/-- **The exact value `R(3,4) = 9`.** -/
theorem ramsey_three_four : Arrows 9 3 4 ∧ ¬ Arrows 8 3 4 :=
  ⟨arrows_three_four, not_arrows_eight_three_four⟩

/- -- !-- Lab Notes -- !--
ANALYSIS (Analyst): The binomial bound `R(3,4) ≤ C(5,2) = 10` is *not* tight; the
gap is closed only by the parity of `9·3 = 27`.  Structurally, the proof needs a
*global* counting constraint (handshake) on top of the *local* recursion used for
R(3,3).  This is the smallest diagonal-adjacent case where pure Erdős–Szekeres
recursion fails to be sharp.

CRITIQUE (Critic): `arrows_three_four` is genuinely non-trivial — it uses
`by_contra`, a reduction to an exact 9-set, `omega` arithmetic, and the handshake
parity lemma; it is not a `decide`-only result.  The lower bound legitimately uses
`decide`, but only to certify a fixed finite construction (allowed). The two are
combined in `ramsey_three_four`.

SYNTHESIS (PI): Reusing the `Arrows` framework and `R(3,3) = 6` from
`Applications.Ramsey`, the exact value `R(3,4) = 9` is established. The handshake
lemma `red_nbrs_sum_even` is a reusable bridge between graph colouring and
arithmetic parity that should generalise to other small Ramsey values.
-/

end RamseyTheory