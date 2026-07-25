/-
# The probabilistic (counting) lower bound for diagonal Ramsey numbers

Building on `Applications.Ramsey` (the two‑colour arrow relation `Arrows n s t`,
where `Arrows n k k` says *every* red/blue colouring of a complete graph on `n`
vertices contains a monochromatic `K_k`), this file formalises the classical
**Erdős probabilistic lower bound**: if there are *more* colourings of `K_n`
than there are colourings containing a monochromatic `K_k`, then a good colouring
exists, so `R(k,k) > n`.

Concretely, encoding a colouring by its set of *red* edges
`R ⊆ edgesOn (univ)` (the off-diagonal pairs of `Fin n`), we count:

* the total number of colourings is `2 ^ C(n,2)`;
* for each `k`-set `T`, the colourings making `T` a red `K_k` number
  `2 ^ (C(n,2) − C(k,2))`, and likewise for blue;
* a union bound over the `C(n,k)` choices of `T` shows that if
  `2 · C(n,k) < 2 ^ C(k,2)` then some colouring avoids *all* monochromatic
  `K_k`'s, i.e. `¬ Arrows n k k`.

## Main results

* `RamseyTheory.not_arrows_of_counting` — the probabilistic lower bound:
  `k ≤ n → 2 * C(n,k) < 2 ^ C(k,2) → ¬ Arrows n k k`.
* `RamseyTheory.not_arrows_of_pow` — a clean exponential corollary using the
  crude bound `C(n,k) ≤ n^k`.
* `RamseyTheory.ramsey_ten_lower` — a concrete instance: `R(10,10) > 16`.

## Lab Notes — see `-- !-- Lab Notes -- !--` blocks below.
-/

import Mathlib
import Applications.Ramsey

open scoped Classical
open SimpleGraph Finset

namespace RamseyTheory

/- -- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the exact small values `R(3,3)=6`, `R(3,4)=9`,
`R(4,4)=18` are governed by *structure* (parity, Paley graphs), but the *growth*
of the diagonal Ramsey number is governed by *counting*: a uniformly random
2-colouring of `K_n` is, with positive probability, free of monochromatic `K_k`
once `n` is exponentially small in `k`.  Conjecture: a fully finite double-count
(no measure theory) suffices, giving `R(k,k) > 2^{(k-1)/2}` constructively.

EXPERIMENT (Experimenter): we model a colouring as a *red edge set*
`R ⊆ edgesOn univ` and count with the Boolean-lattice interval cardinality
`#{A ⊆ Gr : S ⊆ A} = 2^(|Gr|-|S|)` (proved as `card_filter_superset`).  The
"blue" events are handled by the complement involution `A ↦ Gr \ A`
(`card_filter_disjoint`).  A union bound then beats the total count exactly when
`2·C(n,k) < 2^{C(k,2)}`.

COUNTEREXAMPLE HUNT (Critic, see Extra Adversarial Mandate): is the hypothesis
`k ≤ n` load-bearing?  For `k > n` the conclusion `¬ Arrows n k k` is still *true*
(no `k`-clique fits on `n` vertices) but our exponent arithmetic
`2^{|Gr|} = 2^{C(k,2)} · 2^{|Gr|-C(k,2)}` needs `C(k,2) ≤ C(n,2)`, i.e. `k ≤ n`.
So `k ≤ n` is a genuine hypothesis *of this proof*, not of the statement; we keep
it because the interesting (large-`n`) regime always satisfies it.
-/

/-! ## Edges of the complete graph as off-diagonal unordered pairs -/

/-- The edge set spanned by a finite vertex set `T`: all off-diagonal unordered
pairs with both endpoints in `T`.  For `|T| = m` this has `C(m,2)` elements. -/
def edgesOn (T : Finset (Fin n)) : Finset (Sym2 (Fin n)) :=
  T.sym2.filter (fun e => ¬ e.IsDiag)

/-
The number of edges spanned by `T` is `C(|T|, 2)`.
-/
lemma card_edgesOn (T : Finset (Fin n)) : (edgesOn T).card = T.card.choose 2 := by
  rw [ edgesOn ];
  convert Finset.card_powersetCard 2 T using 1;
  refine' Finset.card_bij ( fun x hx => Finset.filter ( fun y => y ∈ x ) T ) _ _ _;
  · simp +contextual [ Finset.mem_powersetCard, Sym2.forall ];
    intro x y hx hy hxy; rw [ show Finset.filter ( fun z => z = x ∨ z = y ) T = { x, y } by ext; aesop ] ; aesop;
  · simp +contextual [ Finset.ext_iff, Sym2.ext_iff ];
    grind;
  · intro b hb; rw [ Finset.mem_powersetCard ] at hb; obtain ⟨ x, y, hxy ⟩ := Finset.card_eq_two.mp hb.2; use Sym2.mk ( x, y ) ; aesop;

/-
`edgesOn` is monotone, so every spanned edge set lies inside the full edge
set `edgesOn univ`.
-/
lemma edgesOn_subset_univ (T : Finset (Fin n)) : edgesOn T ⊆ edgesOn (univ : Finset (Fin n)) := by
  exact Finset.filter_subset_filter _ <| Finset.sym2_mono <| Finset.subset_univ T

/-- The full edge set of `K_n` has `C(n,2)` edges. -/
lemma card_edgesOn_univ : (edgesOn (univ : Finset (Fin n))).card = n.choose 2 := by
  rw [card_edgesOn, Finset.card_univ, Fintype.card_fin]

/-! ## The graph determined by a red edge set -/

/-- The red graph determined by a set `R` of unordered pairs: `i` and `j` are
adjacent iff `i ≠ j` and the pair `s(i,j)` is red. -/
def graphOf (R : Finset (Sym2 (Fin n))) : SimpleGraph (Fin n) :=
  SimpleGraph.fromRel (fun i j => s(i, j) ∈ R)

/-
A vertex set `T` is a red `K_k` exactly when it has `k` vertices and *all*
its spanned edges are red.
-/
lemma isNClique_graphOf_iff (R : Finset (Sym2 (Fin n))) (k : ℕ) (T : Finset (Fin n)) :
    (graphOf R).IsNClique k T ↔ T.card = k ∧ edgesOn T ⊆ R := by
  constructor <;> intro h <;> simp_all +decide [ edgesOn ];
  · simp_all +decide [ Finset.subset_iff, SimpleGraph.isNClique_iff, graphOf ];
    intro x hx hx'; rcases x with ⟨ a, b ⟩ ; simp_all +decide [ fromRel ] ;
    have := h.1 hx.1 hx.2; simp_all +decide [ Sym2.eq_swap ] ;
  · refine' ⟨ _, _ ⟩;
    · intro x hx y hy hxy; have := h.2 ( show s(x, y) ∈ { e ∈ T.sym2 | ¬e.IsDiag } from by aesop ) ; simp_all +decide [ graphOf ] ;
    · exact h.1

/-
A vertex set `T` is a blue `K_k` (a clique of the complement) exactly when it
has `k` vertices and *none* of its spanned edges are red.
-/
lemma isNClique_compl_graphOf_iff (R : Finset (Sym2 (Fin n))) (k : ℕ) (T : Finset (Fin n)) :
    (graphOf R)ᶜ.IsNClique k T ↔ T.card = k ∧ Disjoint (edgesOn T) R := by
  constructor;
  · intro h;
    simp_all +decide [ Finset.disjoint_left, SimpleGraph.isNClique_iff ];
    intro e he; rcases e with ⟨ i, j ⟩ ; simp_all +decide [ edgesOn, SimpleGraph.isIndepSet_iff ] ;
    have := h.1 he.1.1 he.1.2 he.2; simp_all +decide [ graphOf ] ;
  · simp +contextual [ SimpleGraph.isNClique_iff ];
    intro hT hR a ha b hb hab; simp_all +decide [ Finset.disjoint_left, edgesOn ] ;
    unfold graphOf; aesop;

/-! ## Boolean-lattice counting lemmas -/

/-- Interval cardinality: the number of subsets of a ground set `Gr` that contain
a fixed `S ⊆ Gr` is `2 ^ (|Gr| − |S|)`. -/
lemma card_filter_superset {α : Type*} [DecidableEq α] (Gr S : Finset α) (h : S ⊆ Gr) :
    (Gr.powerset.filter (fun A => S ⊆ A)).card = 2 ^ (Gr.card - S.card) := by
  rw [show (2:ℕ)^(Gr.card - S.card) = ((Gr \ S).powerset).card by
        rw [Finset.card_powerset, Finset.card_sdiff_of_subset h]]
  apply Finset.card_bij (fun A _ => A \ S)
  · intro A hA
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA
    simp only [Finset.mem_powerset]
    exact Finset.sdiff_subset_sdiff hA.1 (le_refl S)
  · intro A hA B hB heq
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA hB
    have : (A \ S) ∪ S = (B \ S) ∪ S := by rw [heq]
    rwa [Finset.sdiff_union_of_subset hA.2, Finset.sdiff_union_of_subset hB.2] at this
  · intro B hB
    simp only [Finset.mem_powerset] at hB
    refine ⟨B ∪ S, ?_, ?_⟩
    · simp only [Finset.mem_filter, Finset.mem_powerset]
      refine ⟨Finset.union_subset (hB.trans (Finset.sdiff_subset)) h, Finset.subset_union_right⟩
    · rw [Finset.union_sdiff_right]
      apply Finset.sdiff_eq_self_of_disjoint
      exact (Finset.disjoint_left.2 (fun x hxB hxS => ((Finset.mem_sdiff.1 (hB hxB)).2) hxS))

/-- The number of subsets of `Gr` disjoint from a fixed `S ⊆ Gr` is also
`2 ^ (|Gr| − |S|)` (complement involution `A ↦ Gr \ A`). -/
lemma card_filter_disjoint {α : Type*} [DecidableEq α] (Gr S : Finset α) (h : S ⊆ Gr) :
    (Gr.powerset.filter (fun A => Disjoint S A)).card = 2 ^ (Gr.card - S.card) := by
  rw [← card_filter_superset Gr S h]
  apply Finset.card_bij (fun A _ => Gr \ A)
  · intro A hA
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA ⊢
    refine ⟨Finset.sdiff_subset, ?_⟩
    intro x hxS
    rw [Finset.mem_sdiff]
    exact ⟨h hxS, fun hxA => (Finset.disjoint_left.1 hA.2) hxS hxA⟩
  · intro A hA B hB heq
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA hB
    have : Gr \ (Gr \ A) = Gr \ (Gr \ B) := by rw [heq]
    rwa [Finset.sdiff_sdiff_eq_self hA.1, Finset.sdiff_sdiff_eq_self hB.1] at this
  · intro B hB
    simp only [Finset.mem_filter, Finset.mem_powerset] at hB
    refine ⟨Gr \ B, ?_, ?_⟩
    · simp only [Finset.mem_filter, Finset.mem_powerset]
      refine ⟨Finset.sdiff_subset, ?_⟩
      rw [Finset.disjoint_right]
      intro x hx
      rw [Finset.mem_sdiff] at hx
      exact fun hxS => hx.2 (hB.2 hxS)
    · rw [Finset.sdiff_sdiff_eq_self hB.1]

/-! ## The union bound: existence of a good colouring -/

/-
**Probabilistic existence.** If `k ≤ n` and `2 · C(n,k) < 2^{C(k,2)}`, then
there is a red edge set `R` (a 2-colouring of `K_n`) with no monochromatic
`K_k`: no `k`-set has all its edges red, and no `k`-set has all its edges blue.
-/
lemma exists_good_coloring (hkn : k ≤ n) (hlt : 2 * n.choose k < 2 ^ (k.choose 2)) :
    ∃ R : Finset (Sym2 (Fin n)),
      (∀ T : Finset (Fin n), T.card = k → ¬ edgesOn T ⊆ R) ∧
      (∀ T : Finset (Fin n), T.card = k → ¬ Disjoint (edgesOn T) R) := by
  -- By the union bound, the number of colorings where some k-element subset is monochromatic is strictly less than the total number of colorings.
  have h_union_bound : (∑ T ∈ Finset.powersetCard k (Finset.univ : Finset (Fin n)), ((Finset.powerset (edgesOn (univ : Finset (Fin n)))).filter (fun R => edgesOn T ⊆ R)).card + ∑ T ∈ Finset.powersetCard k (Finset.univ : Finset (Fin n)), ((Finset.powerset (edgesOn (univ : Finset (Fin n)))).filter (fun R => Disjoint (edgesOn T) R)).card) < 2 ^ (n.choose 2) := by
    -- By the properties of binomial coefficients and the union bound, we can show that the sum of the cardinalities of the sets of red and blue colorings is less than $2^{n \choose 2}$.
    have h_sum : ∑ T ∈ Finset.powersetCard k (Finset.univ : Finset (Fin n)), (2 ^ (n.choose 2 - k.choose 2) + 2 ^ (n.choose 2 - k.choose 2)) < 2 ^ (n.choose 2) := by
      simp_all +decide [ ← two_mul, Finset.card_univ ];
      rw [ show 2 ^ n.choose 2 = 2 ^ ( n.choose 2 - k.choose 2 ) * 2 ^ k.choose 2 by rw [ ← pow_add, Nat.sub_add_cancel ( show k.choose 2 ≤ n.choose 2 from Nat.choose_le_choose _ hkn ) ] ] ; nlinarith [ pow_pos ( zero_lt_two' ℕ ) ( n.choose 2 - k.choose 2 ) ] ;
    convert h_sum using 1;
    rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl ];
    intro T hT; rw [ card_filter_superset, card_filter_disjoint ] <;> norm_num [ Finset.mem_powersetCard.mp hT, card_edgesOn ] ;
    · exact edgesOn_subset_univ T;
    · exact edgesOn_subset_univ T;
  contrapose! h_union_bound;
  have h_union_bound : Finset.powerset (edgesOn (univ : Finset (Fin n))) ⊆ Finset.biUnion (Finset.powersetCard k (Finset.univ : Finset (Fin n))) (fun T => (Finset.powerset (edgesOn (univ : Finset (Fin n)))).filter (fun R => edgesOn T ⊆ R) ∪ (Finset.powerset (edgesOn (univ : Finset (Fin n)))).filter (fun R => Disjoint (edgesOn T) R)) := by
    intro R hR; specialize h_union_bound R; by_cases h : ∃ T : Finset ( Fin n ), #T = k ∧ edgesOn T ⊆ R <;> aesop;
  refine' le_trans _ ( Finset.card_mono h_union_bound ) |> le_trans <| _;
  · rw [ Finset.card_powerset, card_edgesOn_univ ];
  · exact le_trans ( Finset.card_biUnion_le ) ( by rw [ ← Finset.sum_add_distrib ] ; exact Finset.sum_le_sum fun _ _ => Finset.card_union_le _ _ )

/-! ## The probabilistic lower bound -/

/-
**Erdős probabilistic lower bound.** If `k ≤ n` and `2 · C(n,k) < 2^{C(k,2)}`,
then `K_n` has a 2-colouring with no monochromatic `K_k`, i.e. `R(k,k) > n`.
-/
theorem not_arrows_of_counting (hkn : k ≤ n) (hlt : 2 * n.choose k < 2 ^ (k.choose 2)) :
    ¬ Arrows n k k := by
  intro h;
  obtain ⟨R, hR⟩ := exists_good_coloring hkn hlt;
  specialize h ( graphOf R ) Finset.univ;
  simp_all +decide [ Finset.card_univ ];
  rcases h with ( ⟨ S, hS ⟩ | ⟨ S, hS ⟩ ) <;> have := isNClique_graphOf_iff R k S <;> have := isNClique_compl_graphOf_iff R k S <;> simp_all +decide [ SimpleGraph.isNClique_iff, SimpleGraph.isNIndepSet_iff ]

/-
**Clean exponential corollary.** Using the crude bound `C(n,k) ≤ n^k`, any `n`
with `2 · n^k < 2^{C(k,2)}` (and `k ≤ n`) satisfies `R(k,k) > n`.
-/
theorem not_arrows_of_pow (hkn : k ≤ n) (hlt : 2 * n ^ k < 2 ^ (k.choose 2)) :
    ¬ Arrows n k k := by
  exact not_arrows_of_counting hkn ( by linarith [ Nat.choose_le_pow n k ] )

/-
**Concrete exponential lower bound:** `R(10,10) > 16`.  (Here `2·16^10 = 2^41
< 2^45 = 2^{C(10,2)}`, so a random 2-colouring of `K₁₆` is `K₁₀`-free in both
colours with positive probability.)
-/
theorem ramsey_ten_lower : ¬ Arrows 16 10 10 :=
  not_arrows_of_pow (by norm_num) (by norm_num [Nat.choose_two_right])

/- -- !-- Lab Notes -- !--
ANALYSIS (Analyst): what survived and why.
* SURVIVED: the full finite double-count.  The two structural pillars are
  `card_filter_superset` (interval cardinality `#[S, Gr] = 2^(|Gr|-|S|)`) and its
  blue mirror `card_filter_disjoint`, obtained from the *same* lemma through the
  complement involution `A ↦ Gr \ A`.  This symmetry is exactly the
  red/blue symmetry of the colouring, made cardinal.
* NEEDED A DIFFERENT DEFINITION: encoding a colouring as a `SimpleGraph` and
  counting `Fintype.card (SimpleGraph (Fin n))` directly is painful.  Switching
  to the *red edge set* model `R ⊆ edgesOn univ` (a `Finset (Sym2 (Fin n))`) made
  the counting a plain `Finset.powerset` computation, with `graphOf` and the two
  `isNClique_*_iff` bridge lemmas translating back to the `Arrows` framework.
* TRUE BUT WEAK AT SMALL k: for `k = 3` the bound only yields `¬ Arrows 3 3 3`
  (since `C(4,3)=4` is not `< 4 = 2^{C(3,2)}/2`), far from the true `R(3,3)=6`.
  The probabilistic method is an *asymptotic* tool; sharpness at small `k`
  belongs to the structural files (`RamseyThreeFour`, `RamseyFourFour`).  This is
  not a defect — it is the qualitative divide between the two halves of Ramsey
  theory.

CRITIQUE (Critic): adversarial review.
* Triviality?  No: the main theorem is a genuine union bound with an exponent
  manipulation `2^{C(n,2)} = 2^{C(k,2)} · 2^{C(n,2)-C(k,2)}`; it is not `decide`,
  not definitional, and not vacuous (`ramsey_ten_lower` exhibits a real instance
  `R(10,10) > 16`).
* Hidden vacuity?  `not_arrows_of_counting` is applied to a nonempty hypothesis
  family: `exists_good_coloring` actually *produces* the avoiding colouring `R`,
  so the negation `¬ Arrows` is witnessed, not vacuous.
* Boundary `k > n` (Extra Adversarial Mandate counterexample): the statement
  `¬ Arrows n k k` stays true there, but the proof's exponent split requires
  `C(k,2) ≤ C(n,2)`, i.e. `k ≤ n`.  We therefore keep `k ≤ n` as an explicit,
  load-bearing hypothesis of the *proof*; it always holds in the lower-bound
  regime (`n` large), so nothing of value is lost.

SYNTHESIS (Principal Investigator): the diagonal Ramsey number obeys two
independent laws.  STRUCTURE pins the small exact values; COUNTING forces the
exponential growth `R(k,k) > 2^{(k-?)/2}`.  This file supplies the second law in
the same `Arrows` vocabulary as the first, so both live in one framework:
`not_arrows_of_counting` (general), `not_arrows_of_pow` (clean exponential
corollary via `C(n,k) ≤ n^k`), and `ramsey_ten_lower` (a concrete witness).
-/

end RamseyTheory