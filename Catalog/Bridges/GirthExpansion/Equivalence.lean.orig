import Catalog.Bridges.GirthExpansion.Basic

/-!
# Girth–Expansion Equivalence for Optimal Small-Set Expanders

This file analyzes the proposed bridge:

> A left-`d`-regular bipartite graph is an *s-optimal small-set expander*
> (every set `X` of `≤ s` left vertices has *exactly* `d·|X|` neighbors)
> **iff** its girth is `≥ 2s+2`.

The adversarial team loop (see Lab Notes) establishes that **the forward
direction is true** but **the converse is false** for `s ≥ 2`, and replaces the
claimed equivalence with the *correct* structural characterizations.
-/

namespace GirthExpansion

open Finset

variable {L R : Type*} [DecidableEq L] [DecidableEq R]

-- !-- Lab Notes -- !--
/-
HYPOTHESIS (Hypothesizer):
  H1 (bold, as stated): OptimalExpander d s ⇔ GirthGe (2s+2).
  H2: OptimalExpander expresses pairwise-disjointness of neighborhoods.
  H3: girth ≥ 6 (no 4-cycle) ⇔ every two left vertices share ≤ 1 neighbor.

EXPERIMENT (Experimenter):
  * Forward direction OptimalExpander ⇒ GirthGe proved (`optimal_imp_girth`).
  * H1's converse FAILS: explicit graph (Fin 2 → Finset (Fin 3),
    N 0 = {0,1}, N 1 = {1,2}) has girth ≥ 6 but |N({0,1})| = 3 ≠ 4 = d·2.
    See `converse_false`.
  * H2 confirmed (`optimal_iff_disjoint`): for s ≥ 2, OptimalExpander d s ⇔
    AllPairsDisjoint — independent of s.
  * H3 confirmed (`no_four_cycle_iff`).

ANALYSIS (Analyst):
  The claim is FALSE as an iff (not merely hard). Root cause: "exactly d·|X|
  neighbors" forces pairwise-DISJOINT neighborhoods, i.e. the graph is a
  vertex-disjoint union of stars (girth = ∞). Girth ≥ 2s+2 only forbids *short
  cycles*; it still allows two vertices to share a single neighbor (an acyclic
  "path" collision) which already breaks optimal expansion. Hence
  optimal ⊊ girth-condition: the implication is strictly one-directional.

CRITIQUE (Critic):
  Guarded the result: the headline `optimal_imp_girth` keeps the general `s`
  and is genuinely proved (no `sorry`, no `decide`-only). The false converse is
  documented by a constructive counterexample `converse_false`. The two true
  structural bridges (`optimal_iff_disjoint`, `no_four_cycle_iff`) replace the
  broken iff with provable content connecting α_G to girth.

SYNTHESIS (PI):
  Verified bridge package:
    optimal ⇒ girth, optimal ⇔ disjoint (s≥2), no-4-cycle ⇔ pairwise ≤1,
    disjoint ⇒ acyclic, and the explicit counterexample to the naive converse.

Disjoint neighborhoods ⟹ no cycle of any length `≥ 2`: a vertex-disjoint
union of stars has infinite girth.
-/
omit [DecidableEq L] in
theorem disjoint_imp_no_cycle (N : L → Finset R) {k : ℕ} (hk : 2 ≤ k)
    (hdisj : AllPairsDisjoint N) : ¬ HasCycle N k := by
  intro h;
  obtain ⟨ a, b, hab, hne ⟩ := cycle_shared_neighbor N hk h;
  obtain ⟨ r, hr ⟩ := hne; specialize hdisj a b hab; simp_all +decide [ Finset.disjoint_left ] ;
  exact hdisj hr.1 hr.2

/-
**Forward bridge (TRUE).** An `s`-optimal small-set expander has girth
`≥ 2s+2`.
-/
theorem optimal_imp_girth (N : L → Finset R) (d s : ℕ)
    (hreg : LeftRegular N d) (hopt : OptimalExpander N d s) :
    GirthGe N s := by
  intro h_contra
  obtain ⟨k, hk2, hks, hc⟩ := h_contra
  have h_le : 2 ≤ s := by
    grind +splitImp
  have hdisj : AllPairsDisjoint N := by
    intro u v huv
    have h_card : (N u ∪ N v).card = d + d := by
      convert hopt { u, v } _ using 1;
      · unfold nbhd; aesop;
      · rw [ Finset.card_insert_of_notMem, Finset.card_singleton ] <;> simp +decide [ huv ] ; ring;
      · exact le_trans ( Finset.card_insert_le _ _ ) ( by norm_num; linarith );
    have := Finset.card_union_add_card_inter ( N u ) ( N v ) ; simp_all +decide ;
    simp_all +decide [ Finset.disjoint_iff_inter_eq_empty, LeftRegular ]
  exact (disjoint_imp_no_cycle N hk2 hdisj) hc

/-
**Expansion structure theorem (TRUE).** For `s ≥ 2`, optimal small-set
expansion is equivalent to *all* neighborhoods being pairwise disjoint — a
condition independent of `s`.
-/
theorem optimal_iff_disjoint (N : L → Finset R) (d s : ℕ) (hs : 2 ≤ s)
    (hreg : LeftRegular N d) :
    OptimalExpander N d s ↔ AllPairsDisjoint N := by
  constructor;
  · intro hopt u v huv;
    have := hopt { u, v } ?_ <;> simp_all +decide;
    have := Finset.card_union_add_card_inter ( N u ) ( N v ) ; simp_all +decide [ nbhd ] ;
    exact Finset.disjoint_iff_inter_eq_empty.mpr ( Finset.card_eq_zero.mp ( by linarith [ hreg u, hreg v ] ) );
  · intro hdisj X hX
    have h_card : (nbhd N X).card = ∑ u ∈ X, (N u).card := by
      exact Finset.card_biUnion fun u hu v hv huv => hdisj u v huv;
    simp_all +decide [ mul_comm, LeftRegular ]

/-
**Genuine girth bridge (TRUE).** Girth `≥ 6` (no 4-cycle) holds iff any two
distinct left vertices share at most one neighbor.
-/
omit [DecidableEq L] in
theorem no_four_cycle_iff (N : L → Finset R) :
    ¬ HasCycle N 2 ↔ ∀ u v : L, u ≠ v → (N u ∩ N v).card ≤ 1 := by
  constructor <;> intro h;
  · intro u v huv;
    contrapose! h;
    obtain ⟨ x, hx, y, hy, hxy ⟩ := Finset.one_lt_card.mp h; use ![u, v], ![x, y]; simp_all +decide [ Function.Injective, Fin.forall_fin_two ] ;
    tauto;
  · rintro ⟨ u, w, hu, hw, hcyc ⟩;
    have := Finset.card_le_card ( show { w 0, w 1 } ⊆ N ( u 0 ) ∩ N ( u 1 ) from ?_ ) ; simp_all +decide [ Finset.card_insert_of_notMem, hw.eq_iff ] ;
    · exact not_lt_of_ge ( h _ _ ( hu.ne ( by decide ) ) ) this;
    · simp_all +decide [ Finset.insert_subset_iff, Fin.forall_fin_two ]

/-! ### Counterexample: the converse of the claimed bridge is false. -/

/-- The witness graph: `L = Fin 2`, `R = Fin 3`, degree `2`, with
`N 0 = {0,1}`, `N 1 = {1,2}`. -/
def Ncex : Fin 2 → Finset (Fin 3) := ![{0, 1}, {1, 2}]

theorem cex_left_regular : LeftRegular Ncex 2 := by
  intro u; fin_cases u <;> decide

/-
The witness has girth `≥ 6`: there is no short cycle of length `≤ 4`.
-/
theorem cex_girth : GirthGe Ncex 2 := by
  intro h;
  obtain ⟨ k, hk₁, hk₂, hk₃ ⟩ := h;
  interval_cases k ; simp_all +decide [ HasCycle ]

/-
The witness is **not** a `2`-optimal expander: `|N({0,1})| = 3 ≠ 4`.
-/
theorem cex_not_optimal : ¬ OptimalExpander Ncex 2 2 := by
  simp +decide [OptimalExpander]

/-- **Converse is FALSE.** There is a left-regular bipartite graph with girth
`≥ 2s+2` that is *not* an `s`-optimal small-set expander (here `s = 2`).
Thus the proposed equivalence holds only in the forward direction. -/
theorem converse_false :
    ∃ (N : Fin 2 → Finset (Fin 3)) (d s : ℕ),
      LeftRegular N d ∧ GirthGe N s ∧ ¬ OptimalExpander N d s :=
  ⟨Ncex, 2, 2, cex_left_regular, cex_girth, cex_not_optimal⟩

end GirthExpansion