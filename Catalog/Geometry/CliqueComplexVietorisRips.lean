/-
# Extremes of the Vietoris–Rips Filtration, and Complement Duality

Building on `Catalog/Geometry/CliqueComplexFlag.lean`, this file pins down the two
*extremes* of the Vietoris–Rips filtration `ε ↦ vietorisRips d ε` and records the
self-duality of the clique construction under graph complementation.

## Main results

* `vietorisRips_full_of_bounded`      — above the diameter, the VR complex is the
                                         full simplex (every finite set is a face).
* `vietorisRips_discrete_of_separated`— below the minimum separation, the VR complex
                                         is discrete (faces are exactly the `≤ 1`-sets).
* `independenceComplex`               — the independence complex of a graph.
* `mem_independenceComplex`           — `independenceComplex G = cliqueComplex Gᶜ`.
* `independenceComplex_isFlag`        — flagness transfers to independence complexes.

-- !-- Lab Notebook -- !--
Hypothesis: the qualitative shape of the VR filtration is fixed by two thresholds
  (diameter above, minimum separation below), and the clique construction is
  self-dual under complementation.
Result: proved both extremes (full simplex above the diameter, discrete below the
  separation) and the complement-duality `independenceComplex G = cliqueComplex Gᶜ`,
  from which flagness is inherited for free.
Insight: face membership in `vietorisRips d ε` is a finite conjunction of scalar
  inequalities `d u v ≤ ε`; bounding all of them makes every pair an edge (full
  simplex), while strictly violating all of them kills every edge (discrete).  The
  independence complex is literally the clique complex of the complement, so the
  entire base theory dualizes by substituting `Gᶜ`.
Failure analysis: the "discrete" direction needs *strict* separation `ε < d u v`;
  with only `ε ≤ d u v` a boundary pair could still be an edge, so the threshold
  characterization would fail at the critical scale.
-- !-- Lab Notebook -- !--
-/
import Mathlib
import Geometry.CliqueComplexFlag

namespace CliqueComplexFlag

open scoped Classical

universe u
variable {V : Type u}

/-! ## The two extremes of the Vietoris–Rips filtration -/

/-- **Above the diameter the Vietoris–Rips complex is the full simplex.**
If every dissimilarity is `≤ ε`, then *every* finite vertex set is a face. -/
theorem vietorisRips_full_of_bounded {d : V → V → ℝ} {ε : ℝ}
    (h : ∀ u v, d u v ≤ ε) (s : Finset V) :
    s ∈ (vietorisRips d ε).faces := by
  -- !-- every distinct pair is an edge of the VR graph (both dissimilarities ≤ ε),
  --     so every finite set is a clique. -- !--
  rw [vietorisRips, mem_cliqueComplex, SimpleGraph.isClique_iff]
  intro u _ v _ huv
  exact ⟨huv, h u v, h v u⟩

/-- **Below the minimum separation the Vietoris–Rips complex is discrete.**
If distinct vertices are strictly separated (`ε < d u v`), then the faces are
*exactly* the sets of cardinality at most one. -/
theorem vietorisRips_discrete_of_separated {d : V → V → ℝ} {ε : ℝ}
    (h : ∀ u v, u ≠ v → ε < d u v) (s : Finset V) :
    s ∈ (vietorisRips d ε).faces ↔ s.card ≤ 1 := by
  -- !-- a set of size ≥ 2 contains a distinct pair, which cannot be an edge since
  --     `ε < d u v` contradicts `d u v ≤ ε`; sets of size ≤ 1 are vacuously cliques. -- !--
  rw [vietorisRips, mem_cliqueComplex, SimpleGraph.isClique_iff]
  constructor
  · intro hclique
    by_contra hcard
    rw [not_le] at hcard
    obtain ⟨u, hu, v, hv, huv⟩ := Finset.one_lt_card.1 hcard
    obtain ⟨_, h1, _⟩ := hclique (by exact_mod_cast hu) (by exact_mod_cast hv) huv
    exact absurd h1 (not_le.2 (h u v huv))
  · intro hcard u hu v hv huv
    exfalso
    have : 2 ≤ s.card := by
      apply Finset.one_lt_card.2
      exact ⟨u, by exact_mod_cast hu, v, by exact_mod_cast hv, huv⟩
    omega

/-! ## The independence complex and complement duality -/

/-- The **independence complex** `independenceComplex G`: faces are the finite
*independent* sets of `G` (no two distinct elements adjacent). -/
def independenceComplex (G : SimpleGraph V) : ASC V where
  faces := {s : Finset V | G.IsIndepSet (↑s : Set V)}
  down_closed := by
    intro s t hst ht
    exact ht.mono (by exact_mod_cast hst)

/-- **Complement duality:** a set is a face of `independenceComplex G` iff it is a
face of `cliqueComplex Gᶜ`.  Independence in `G` is exactly cliqueness in `Gᶜ`. -/
theorem mem_independenceComplex {G : SimpleGraph V} {s : Finset V} :
    s ∈ (independenceComplex G).faces ↔ s ∈ (cliqueComplex Gᶜ).faces := by
  -- !-- `G.IsIndepSet s ↔ Gᶜ.IsClique s`, by unfolding `compl_adj`. -- !--
  simp only [independenceComplex, mem_cliqueComplex, Set.mem_setOf_eq]
  unfold SimpleGraph.IsIndepSet SimpleGraph.IsClique Set.Pairwise
  constructor
  · intro hind a ha b hb hab
    rw [SimpleGraph.compl_adj]
    exact ⟨hab, hind ha hb hab⟩
  · intro hcl a ha b hb hab
    have := hcl ha hb hab
    rw [SimpleGraph.compl_adj] at this
    exact this.2

/-- **The independence complex is itself a clique complex**, namely of `Gᶜ`. -/
theorem independenceComplex_eq_cliqueComplex (G : SimpleGraph V) :
    independenceComplex G = cliqueComplex Gᶜ := by
  -- !-- pointwise from `mem_independenceComplex`. -- !--
  apply ASC.ext
  ext s
  exact mem_independenceComplex

/-- **Flagness transfers for free:** every independence complex is a flag complex,
since it is the clique complex of the complement. -/
theorem independenceComplex_isFlag (G : SimpleGraph V) :
    IsFlag (independenceComplex G) := by
  -- !-- `independenceComplex G = cliqueComplex Gᶜ` and clique complexes are flag. -- !--
  rw [independenceComplex_eq_cliqueComplex]
  exact cliqueComplex_isFlag Gᶜ

end CliqueComplexFlag