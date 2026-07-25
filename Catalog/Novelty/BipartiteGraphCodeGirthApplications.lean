import Novelty.BipartiteGraphCodeGirth

/-!
# Consequences of the girth–minimum-distance bound

Building on `Catalog/Novelty/BipartiteGraphCodeGirth.lean`, we record concrete
consequences of `BipartiteGraphCode.girth_bounds_min_distance` that show the bound
is **non-vacuous** and recover familiar special cases of coding theory.

* `singleton_not_codeword` — a single left vertex is never a codeword of `B(G)`
  when `d ≥ 1`; in particular the minimum distance is genuinely `≥ 2` whenever a
  codeword exists. This shows the parity (even-degree) condition has bite.
* `codeword_card_ge_two_of_egirth_four` — the girth `≥ 4` case (`k = 1`): every
  non-empty codeword has at least two coordinates. (Equivalently: distinct
  columns of the parity-check matrix are nonzero — minimum distance `≥ 2`.)
* `codeword_card_ge_of_egirth` — the general restatement: girth `≥ 2k+2` forces
  every non-empty codeword to have `≥ k+1` coordinates.

-- !-- Lab Notes -- !--
**Hypothesis (Hypothesizer).** If the girth bound is sharp it should already pin
down the small-distance regime: girth `≥ 4` ⟺ no repeated columns ⟺ distance
`≥ 2`. A degenerate "codeword" of weight `1` should be impossible for `d ≥ 1`.

**Experiment (Experimenter).** `singleton_not_codeword` is proved directly from
left-regularity (a degree-`d` left vertex is seen an *odd* number — exactly once —
of times by each of its neighbours). The `k = 1` corollary specialises the main
theorem. Both compile with `0` sorries.

**Analysis (Analyst).** The singleton obstruction is *independent* of girth: it
holds as soon as `d ≥ 1`. The girth hypothesis is what pushes the bound past `2`.
This cleanly separates the "parity" content from the "expansion/girth" content.

**Critique (Critic).** The corollaries genuinely use the main theorem (not a
re-proof). `singleton_not_codeword` needs only `1 ≤ d`, exhibiting a weaker
hypothesis than the main theorem and confirming the bound is not vacuous.

**Synthesis (PI).** Together with the main file these give a self-contained
treatment of how combinatorial girth controls the minimum distance of `B(G)`.
-/

namespace BipartiteGraphCode

open SimpleGraph Finset

variable {L R : Type*} [Fintype L] [Fintype R] [DecidableEq L] [DecidableEq R]

omit [Fintype L] [DecidableEq L] [DecidableEq R] in
/-- A single left vertex is never a codeword: if `l` has at least one neighbour
(`1 ≤ d`), some right vertex sees `l` an odd number (one) of times. -/
theorem singleton_not_codeword
    (inc : L → R → Prop) [∀ l r, Decidable (inc l r)]
    (d : ℕ) (hd : 1 ≤ d)
    (hreg : ∀ l, (univ.filter (fun r => inc l r)).card = d)
    (l : L) :
    ¬ (∀ r, Even (({l} : Finset L).filter (fun l' => inc l' r)).card) := by
  intro hcode
  -- `l` has a neighbour `r`.
  have hpos : 0 < (univ.filter (fun r => inc l r)).card := by rw [hreg l]; omega
  obtain ⟨r, hr⟩ := Finset.card_pos.mp hpos
  simp only [Finset.mem_filter] at hr
  -- the filtered singleton is exactly `{l}`, of odd card `1`.
  have hcard : (({l} : Finset L).filter (fun l' => inc l' r)).card = 1 := by
    rw [Finset.filter_singleton, if_pos hr.2, Finset.card_singleton]
  have := hcode r
  rw [hcard] at this
  simp [Nat.even_iff] at this

/-- **Girth `≥ 4` (the `k = 1` case).** A simple left-`d`-regular bipartite graph
with `d ≥ 2` and girth at least `4` has minimum distance at least `2`: every
non-empty codeword of `B(G)` has at least two coordinates. -/
theorem codeword_card_ge_two_of_egirth_four
    (inc : L → R → Prop) [∀ l r, Decidable (inc l r)]
    (d : ℕ) (hd : 2 ≤ d)
    (hreg : ∀ l, (univ.filter (fun r => inc l r)).card = d)
    (hgirth : (4 : ℕ∞) ≤ (biGraph inc).egirth)
    (S : Finset L) (hS : S.Nonempty)
    (hcode : ∀ r, Even (S.filter (fun l => inc l r)).card) :
    2 ≤ S.card := by
  have h4 : (2 * 1 + 2 : ℕ∞) ≤ (biGraph inc).egirth := by
    have : (2 * 1 + 2 : ℕ∞) = 4 := by norm_num
    rw [this]; exact hgirth
  have := girth_bounds_min_distance inc d 1 hd hreg h4 S hS hcode
  simpa using this

/-- **General restatement.** Girth at least `2k+2` forces every non-empty codeword
to have at least `k+1` coordinates: the minimum distance of `B(G)` is `≥ k+1`. -/
theorem codeword_card_ge_of_egirth
    (inc : L → R → Prop) [∀ l r, Decidable (inc l r)]
    (d k : ℕ) (hd : 2 ≤ d)
    (hreg : ∀ l, (univ.filter (fun r => inc l r)).card = d)
    (hgirth : (2 * k + 2 : ℕ∞) ≤ (biGraph inc).egirth)
    (S : Finset L) (hS : S.Nonempty)
    (hcode : ∀ r, Even (S.filter (fun l => inc l r)).card) :
    k + 1 ≤ S.card :=
  girth_bounds_min_distance inc d k hd hreg hgirth S hS hcode

end BipartiteGraphCode