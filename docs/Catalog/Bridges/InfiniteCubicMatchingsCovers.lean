/-
# Coverings: transferring matchings from a base graph to an infinite cover

A map `φ : V(G) → V(K)` which is a local isomorphism at *every* vertex (`IsLocalIsoAt`) is a
covering map in the graph-theoretic sense.  Perfect matchings pull back along such maps, and
therefore so do the Berge–Fulkerson and Fan–Raspaud properties.

The consequence for the infinite theory is `bergeFulkerson_of_covers_finite`: *the finite
Berge–Fulkerson conjecture already implies the Berge–Fulkerson property for every graph —
however large — that covers a finite cubic bridgeless graph.*  This covers all the standard
infinite examples (ℤ-covers and other regular covers of finite snarks and prisms), with no
compactness argument needed.
-/
import Bridges.InfiniteCubicMatchingsCompactness

namespace Bridges.InfiniteCubicMatchings

universe u v

variable {V : Type u} {W : Type v} {G : SimpleGraph V} {K : SimpleGraph W}

namespace PerfectMatching

/-- The partner map obtained by pulling a perfect matching of `K` back along a covering. -/
noncomputable def pullbackPartner (φ : V → W) (hcov : ∀ v, IsLocalIsoAt G K φ v)
    (M : PerfectMatching K) (v : V) : V :=
  Classical.choose ((hcov v).surj (M.partner (φ v)) (M.isAdj (φ v)))

lemma pullbackPartner_adj (φ : V → W) (hcov : ∀ v, IsLocalIsoAt G K φ v)
    (M : PerfectMatching K) (v : V) : G.Adj v (pullbackPartner φ hcov M v) :=
  (Classical.choose_spec ((hcov v).surj (M.partner (φ v)) (M.isAdj (φ v)))).1

lemma pullbackPartner_map (φ : V → W) (hcov : ∀ v, IsLocalIsoAt G K φ v)
    (M : PerfectMatching K) (v : V) :
    φ (pullbackPartner φ hcov M v) = M.partner (φ v) :=
  (Classical.choose_spec ((hcov v).surj (M.partner (φ v)) (M.isAdj (φ v)))).2

/-- Pulling back a perfect matching along a covering map. -/
noncomputable def pullback (φ : V → W) (hcov : ∀ v, IsLocalIsoAt G K φ v)
    (M : PerfectMatching K) : PerfectMatching G where
  partner := pullbackPartner φ hcov M
  isAdj := pullbackPartner_adj φ hcov M
  invol v := by
    set y := pullbackPartner φ hcov M v with hy
    have hvy : G.Adj v y := pullbackPartner_adj φ hcov M v
    have h1 : φ (pullbackPartner φ hcov M y) = φ v := by
      rw [pullbackPartner_map φ hcov M y, hy, pullbackPartner_map φ hcov M v, M.invol]
    exact (hcov y).inj _ _ (pullbackPartner_adj φ hcov M y) hvy.symm h1

/-- An edge belongs to the pulled back matching exactly when its image belongs to the original
one. -/
lemma mem_pullback_edges (φ : V → W) (hcov : ∀ v, IsLocalIsoAt G K φ v)
    (M : PerfectMatching K) (u w : V) (huw : G.Adj u w) :
    s(u, w) ∈ (pullback φ hcov M).edges ↔ s(φ u, φ w) ∈ M.edges := by
  rw [mem_edges, mem_edges]
  constructor
  · intro h
    rw [← pullbackPartner_map φ hcov M u]
    exact congrArg φ (by rw [← h]; rfl)
  · intro h
    refine (hcov u).inj _ _ (pullbackPartner_adj φ hcov M u) huw ?_
    show φ (pullbackPartner φ hcov M u) = φ w
    rw [pullbackPartner_map φ hcov M u, h]

end PerfectMatching

/-- **Berge–Fulkerson lifts along coverings.** -/
theorem BergeFulkerson.of_covering (φ : V → W) (hcov : ∀ v, IsLocalIsoAt G K φ v)
    (hK : BergeFulkerson K) : BergeFulkerson G := by
  obtain ⟨M, hM⟩ := hK
  refine ⟨fun i => PerfectMatching.pullback φ hcov (M i), ?_⟩
  intro e
  induction e with
  | _ u w =>
    intro hE
    have huw : G.Adj u w := hE
    have hset : {i : Fin 6 | s(u, w) ∈ (PerfectMatching.pullback φ hcov (M i)).edges}
        = {i : Fin 6 | s(φ u, φ w) ∈ (M i).edges} := by
      ext i
      exact PerfectMatching.mem_pullback_edges φ hcov (M i) u w huw
    rw [hset]
    exact hM _ (by simpa using (hcov u).adj w huw)

/-- **Fan–Raspaud lifts along coverings.** -/
theorem FanRaspaud.of_covering (φ : V → W) (hcov : ∀ v, IsLocalIsoAt G K φ v)
    (hK : FanRaspaud K) : FanRaspaud G := by
  obtain ⟨M, hM⟩ := hK
  refine ⟨fun i => PerfectMatching.pullback φ hcov (M i), ?_⟩
  rw [Set.eq_empty_iff_forall_notMem]
  intro e
  induction e with
  | _ u w =>
    rintro ⟨⟨h0, h1⟩, h2⟩
    have huw : G.Adj u w := by
      have := (PerfectMatching.pullback φ hcov (M 0)).edges_subset_edgeSet h0
      simpa using this
    rw [PerfectMatching.mem_pullback_edges φ hcov _ u w huw] at h0 h1 h2
    have : s(φ u, φ w) ∈ (M 0).edges ∩ (M 1).edges ∩ (M 2).edges := ⟨⟨h0, h1⟩, h2⟩
    rw [hM] at this
    exact this

/-- **The finite Berge–Fulkerson conjecture implies the infinite one for covers.**
Any graph, of any cardinality, which covers a finite cubic bridgeless graph satisfies the
Berge–Fulkerson property as soon as the finite conjecture holds. -/
theorem bergeFulkerson_of_covers_finite {W : Type} [Fintype W] {K : SimpleGraph W}
    (φ : V → W) (hcov : ∀ v, IsLocalIsoAt G K φ v) (hcub : IsCubic K) (hbr : Bridgeless K)
    (hBF : FiniteBergeFulkersonConjecture) : BergeFulkerson G :=
  BergeFulkerson.of_covering φ hcov (hBF W inferInstance K hcub hbr)

/-- Unconditionally: a cover of a 3-edge-colourable graph satisfies Berge–Fulkerson. -/
theorem bergeFulkerson_of_covers_threeEdgeColorable (φ : V → W)
    (hcov : ∀ v, IsLocalIsoAt G K φ v) (hK : ProperThreeEdgeColoring K) : BergeFulkerson G :=
  BergeFulkerson.of_covering φ hcov hK.bergeFulkerson

end Bridges.InfiniteCubicMatchings