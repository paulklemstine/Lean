/-
  Cliques, and Hadwiger's Conjecture in the Small-Graph Range
  ==========================================================

  Two unconditional results that hold for *every* `k`, and so cut off the
  "trivial range" of Hadwiger's conjecture:

  * `Hadwiger.completeMinor_of_isNClique` : a clique of size `n` is in
                                            particular a `Kₙ` minor (the
                                            Hadwiger number dominates the clique
                                            number).
  * `Hadwiger.hadwiger_of_card_le_succ`   : **Hadwiger's conjecture holds for
                                            every graph with at most `k+1`
                                            vertices** — such a graph fails to be
                                            `k`-colourable only if it is the
                                            complete graph `K_{k+1}` itself.

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): the extremal case of Hadwiger's conjecture is
    `G = K_{k+1}`; below that vertex count the conjecture should be provable
    outright for all `k`, giving an unconditional theorem covering infinitely
    many open instances (`k ≥ 5`) in a restricted regime.
  Experiment (Experimenter): if `|V| ≤ k` a mere injection `V ↪ Fin k` colours
    `G`, so `|V| = k+1`; and if two vertices `u ≠ v` were non-adjacent, the
    colouring "identify `v` with `u`, and be injective elsewhere" uses only `k`
    colours.  Hence `G = ⊤`, and the singleton branch sets on a clique give the
    `K_{k+1}` model.
  Analysis (Analyst): the argument isolates *why* the conjecture is hard: the
    only obstruction in the small regime is the complete graph, whereas for
    `|V| > k+1` genuinely global structure (contraction) is needed.
  Critique (Critic): the identification colouring must be checked on the edge
    `v–u` — this is exactly where non-adjacency of `u` and `v` is used, so the
    hypothesis is load-bearing rather than decorative.
  Synthesis (PI): together with `hadwiger_monotone` these give unconditional
    fragments of every open case of the conjecture.
  -- !-- Lab Notes -- !--
-/
import Mathlib
import Probability.HadwigerWagner

namespace Hadwiger

open SimpleGraph

variable {V : Type*} {G : SimpleGraph V}

/-- A clique of size `n` yields a `Kₙ` minor (singleton branch sets). -/
theorem completeMinor_of_isNClique [DecidableEq V] {n : ℕ} {s : Finset V}
    (hs : G.IsNClique n s) : CompleteMinor n G := by
  classical
  let e : Fin n ≃ s := (Finset.equivFinOfCardEq hs.card_eq).symm
  refine completeMinor_of_branches (fun i => {(e i : V)}) (fun i => ⟨_, rfl⟩) ?_
    (fun i => setConnected_singleton _) ?_
  · intro i j hij
    have hne : (e i : V) ≠ (e j : V) := by
      intro hcon
      exact hij (e.injective (Subtype.ext hcon))
    simpa using hne
  · intro i j hij
    have hne : (e i : V) ≠ (e j : V) := by
      intro hcon
      exact hij (e.injective (Subtype.ext hcon))
    exact ⟨_, rfl, _, rfl, hs.isClique (e i).2 (e j).2 hne⟩

/-- If `|V| ≤ k` then every graph on `V` is `k`-colourable. -/
theorem colorable_of_card_le [Fintype V] {k : ℕ} (hcard : Fintype.card V ≤ k) :
    G.Colorable k := by
  obtain ⟨f⟩ := Function.Embedding.nonempty_of_card_le (α := V) (β := Fin k) (by simpa using hcard)
  exact ⟨Coloring.mk f fun {x y} hxy hcon => (G.ne_of_adj hxy) (f.injective hcon)⟩

/-- A graph on `k+1` vertices that is not `k`-colourable is complete. -/
theorem eq_top_of_not_colorable_of_card_le [Fintype V] {k : ℕ}
    (hcard : Fintype.card V ≤ k + 1) (h : ¬ G.Colorable k) : G = ⊤ := by
  classical
  ext u v
  simp only [top_adj]
  refine ⟨fun hadj => G.ne_of_adj hadj, fun hne => ?_⟩
  by_contra hadj
  -- identify `v` with `u`; the remaining `k` vertices get distinct colours
  have hcardsub : Fintype.card {x : V // x ≠ v} ≤ k := by
    have h1 : Fintype.card {x : V // x ≠ v} = Fintype.card V - 1 := by
      simp [Fintype.card_subtype_compl]
    have h2 : 0 < Fintype.card V := Fintype.card_pos_iff.mpr ⟨v⟩
    omega
  obtain ⟨e⟩ := Function.Embedding.nonempty_of_card_le (α := {x : V // x ≠ v}) (β := Fin k)
    (by simpa using hcardsub)
  refine h ⟨Coloring.mk (fun x => if hx : x = v then e ⟨u, hne⟩ else e ⟨x, hx⟩) ?_⟩
  intro x y hxy hcon
  dsimp only at hcon
  by_cases hxv : x = v <;> by_cases hyv : y = v
  · exact (G.ne_of_adj hxy) (hxv.trans hyv.symm)
  · rw [dif_pos hxv, dif_neg hyv] at hcon
    have : u = y := congrArg Subtype.val (e.injective hcon)
    exact hadj (by rw [← this] at hxy; rw [hxv] at hxy; exact hxy.symm)
  · rw [dif_neg hxv, dif_pos hyv] at hcon
    have : x = u := congrArg Subtype.val (e.injective hcon)
    exact hadj (by rw [this] at hxy; rw [hyv] at hxy; exact hxy)
  · rw [dif_neg hxv, dif_neg hyv] at hcon
    exact (G.ne_of_adj hxy) (congrArg Subtype.val (e.injective hcon))

/-- **Hadwiger's conjecture holds for all graphs with at most `k+1` vertices**,
for every `k` — including the open cases `k ≥ 5`. -/
theorem hadwiger_of_card_le_succ [Fintype V] {k : ℕ} (hcard : Fintype.card V ≤ k + 1)
    (h : ¬ G.Colorable k) : CompleteMinor (k + 1) G := by
  classical
  have htop : G = ⊤ := eq_top_of_not_colorable_of_card_le hcard h
  have hcardeq : Fintype.card V = k + 1 := by
    rcases Nat.lt_or_ge (Fintype.card V) (k + 1) with hlt | hge
    · exact absurd (colorable_of_card_le (by omega)) h
    · omega
  have hclique : G.IsNClique (k + 1) Finset.univ := by
    refine ⟨?_, by simpa using hcardeq⟩
    intro x _ y _ hxy
    rw [htop]
    exact hxy
  exact completeMinor_of_isNClique hclique

end Hadwiger