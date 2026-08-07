/-
  Minors in the Erdős–Rényi Random Graph
  ======================================

  A bridge between the minor theory developed here and the elementary
  `G(n,p)` model of `ErdosRenyiThreshold.lean`.  The excluded-minor
  characterisation of forests (`HadwigerForest.lean`) says that in the random
  graph the events "has a `K₃` minor" and "is not a forest" are *literally the
  same event*, and the independence computation of the `G(n,p)` model then gives
  an explicit lower bound for its probability.

  Main results:

  * `Hadwiger.RandomGraph.hasK3Minor_eq_hasCycle` : the two events coincide.
  * `Hadwiger.RandomGraph.prob_hasK3Minor_eq_prob_hasCycle`.
  * `Hadwiger.RandomGraph.prob_mono`               : monotonicity of `Prob` in the
                                                     event.
  * `Hadwiger.RandomGraph.pow_three_le_prob_hasK3Minor` : `p³ ≤ P(K₃ ≼ G(n,p))`
                                                     for `n ≥ 3`.

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): topological (minor) events should be expressible in
    the elementary configuration model, and the `K₃`-minor event should be
    exactly the complement of acyclicity.
  Experiment (Experimenter): `completeMinor_three_iff_not_isAcyclic` transfers
    verbatim to `graphOf s`; the quantitative bound comes from the fixed triangle
    `{01, 02, 12}`, whose containment probability is `p³` by
    `ErdosRenyi.prob_contains_subset`, together with monotonicity of `Prob`.
  Analysis (Analyst): the bound is tight in order for `p` bounded away from `0`
    and shows the `K₃`-minor event is *not* rare, in contrast with the `K₃`
    *subgraph* event whose expected count is `binom(n,3) p³`.
  Critique (Critic): the lower bound uses only one triangle, so it does not
    capture the `p ~ 1/n` threshold for cycles; sharpening it needs a second
    moment over all cycles, recorded as a future direction.
  Synthesis (PI): the probabilistic and structural halves of the catalog now
    talk to each other through a proved event identity rather than an analogy.
  -- !-- Lab Notes -- !--
-/
import Mathlib
import Probability.HadwigerForest
import Probability.ErdosRenyiThreshold

namespace Hadwiger.RandomGraph

open SimpleGraph ErdosRenyi Finset
open scoped Classical

/-- The event that the random graph has a `K₃` minor. -/
noncomputable def hasK3Minor (n : ℕ) : Finset (Finset (Edge n)) :=
  Finset.univ.filter (fun s => CompleteMinor 3 (graphOf s))

/-- The event that the random graph contains a cycle. -/
noncomputable def hasCycle (n : ℕ) : Finset (Finset (Edge n)) :=
  Finset.univ.filter (fun s => ¬ (graphOf s).IsAcyclic)

/-- In `G(n,p)`, having a `K₃` minor is the *same event* as containing a
cycle. -/
theorem hasK3Minor_eq_hasCycle (n : ℕ) : hasK3Minor n = hasCycle n := by
  ext s
  simp only [hasK3Minor, hasCycle, Finset.mem_filter, Finset.mem_univ, true_and]
  exact completeMinor_three_iff_not_isAcyclic

theorem prob_hasK3Minor_eq_prob_hasCycle (p : ℝ) (n : ℕ) :
    Prob p (hasK3Minor n) = Prob p (hasCycle n) := by
  rw [hasK3Minor_eq_hasCycle]

/-- `Prob` is monotone in the event. -/
theorem prob_mono {n : ℕ} {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {E F : Finset (Finset (Edge n))} (h : E ⊆ F) : Prob p E ≤ Prob p F :=
  Finset.sum_le_sum_of_subset_of_nonneg h (fun s _ _ => mass_nonneg hp0 hp1 s)

/-- **A quantitative lower bound.**  On at least three vertices, the probability
that `G(n,p)` has a `K₃` minor is at least `p³`: already the single triangle
`{01, 02, 12}` forces one. -/
theorem pow_three_le_prob_hasK3Minor {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (n : ℕ) :
    p ^ 3 ≤ Prob p (hasK3Minor (n + 3)) := by
  classical
  set a : Fin (n + 3) := ⟨0, by omega⟩ with ha
  set b : Fin (n + 3) := ⟨1, by omega⟩ with hb
  set c : Fin (n + 3) := ⟨2, by omega⟩ with hc
  have hab : a ≠ b := by simp [ha, hb]
  have hac : a ≠ c := by simp [ha, hc]
  have hbc : b ≠ c := by simp [hb, hc]
  have dab : ¬ (s(a, b) : Sym2 (Fin (n + 3))).IsDiag := by simpa using hab
  have dac : ¬ (s(a, c) : Sym2 (Fin (n + 3))).IsDiag := by simpa using hac
  have dbc : ¬ (s(b, c) : Sym2 (Fin (n + 3))).IsDiag := by simpa using hbc
  set eab : Edge (n + 3) := ⟨s(a, b), dab⟩ with heab
  set eac : Edge (n + 3) := ⟨s(a, c), dac⟩ with heac
  set ebc : Edge (n + 3) := ⟨s(b, c), dbc⟩ with hebc
  set T : Finset (Edge (n + 3)) := {eab, eac, ebc} with hT
  have hTcard : T.card = 3 := by
    have h1 : eab ≠ eac := by
      simp [heab, heac, Subtype.ext_iff, hac, Ne.symm hab, hbc]
    have h2 : eab ≠ ebc := by
      simp [heab, hebc, Subtype.ext_iff, hab, hac, hbc]
    have h3 : eac ≠ ebc := by
      simp [heac, hebc, Subtype.ext_iff, hab, hac, Ne.symm hbc]
    simp [hT, Finset.card_insert_of_notMem, h1, h2, h3]
  have hsub : Finset.univ.filter (fun s : Finset (Edge (n + 3)) => T ⊆ s) ⊆
      hasK3Minor (n + 3) := by
    intro s hs
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hs
    have hmem : ∀ e ∈ T, e ∈ s := fun e he => hs he
    have hadj : ∀ (x y : Fin (n + 3)) (hxy : x ≠ y),
        (⟨s(x, y), by simpa using hxy⟩ : Edge (n + 3)) ∈ s → (graphOf s).Adj x y := by
      intro x y hxy hin
      simp only [graphOf, SimpleGraph.fromEdgeSet_adj]
      exact ⟨⟨⟨s(x, y), by simpa using hxy⟩, by simpa using hin, rfl⟩, hxy⟩
    have Aab : (graphOf s).Adj a b := hadj a b hab (hmem eab (by simp [hT]))
    have Aac : (graphOf s).Adj a c := hadj a c hac (hmem eac (by simp [hT]))
    have Abc : (graphOf s).Adj b c := hadj b c hbc (hmem ebc (by simp [hT]))
    simp only [hasK3Minor, Finset.mem_filter, Finset.mem_univ, true_and]
    exact completeMinor_three_of_triple (S0 := {a}) (S1 := {b}) (S2 := {c})
      ⟨a, rfl⟩ ⟨b, rfl⟩ ⟨c, rfl⟩ (by simpa using hab) (by simpa using hac) (by simpa using hbc)
      (setConnected_singleton a) (setConnected_singleton b) (setConnected_singleton c)
      ⟨a, rfl, b, rfl, Aab⟩ ⟨a, rfl, c, rfl, Aac⟩ ⟨b, rfl, c, rfl, Abc⟩
  calc p ^ 3 = Prob p (Finset.univ.filter (fun s : Finset (Edge (n + 3)) => T ⊆ s)) := by
        rw [prob_contains_subset, hTcard]
    _ ≤ Prob p (hasK3Minor (n + 3)) := prob_mono hp0 hp1 hsub

end Hadwiger.RandomGraph