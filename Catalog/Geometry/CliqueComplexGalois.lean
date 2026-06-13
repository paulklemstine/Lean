/-
# The One-Skeleton / Clique-Complex Galois Connection

Building on `Catalog/Geometry/CliqueComplexFlag.lean`, this file develops the
order-theoretic backbone of the clique-complex construction.  The two functors

* `cliqueComplex : SimpleGraph V → ASC V`   (denoted `Δ`), and
* `oneSkeleton  : ASC V → SimpleGraph V`    (denoted `sk`),

form a Galois connection between the poset of simple graphs (ordered by `≤`) and
the poset of abstract simplicial complexes (ordered by face inclusion).

## Main results

* `cliqueComplex_mono`             — `Δ` is monotone in the graph.
* `oneSkeleton_mono`              — `sk` is monotone in the complex.
* `le_cliqueComplex_oneSkeleton` — the unit `K ⊆ Δ(sk K)`, needing only downward closure.
* `cliqueComplex_oneSkeleton_idem` — `Δ(sk(Δ G)) = Δ G`, the closure law.
* `cliqueComplex_galois`         — the adjunction `Δ G ⊆ K ↔ G ≤ sk K` for flag
                                    complexes containing all singletons.

-- !-- Lab Notebook -- !--
Hypothesis: `oneSkeleton ∘ cliqueComplex = id` and `flag_eq_cliqueComplex` are
  the two halves of a Galois connection `Δ ⊣ sk` between graphs and complexes.
Result: proved monotonicity of both functors, the unconditional unit
  `K ⊆ Δ(sk K)`, idempotence of the closure `Δ ∘ sk` on images of `Δ`, and the
  full adjunction on flag complexes with all singletons.
Insight: the unit needs ONLY downward closure (every face's pairs are faces, so a
  face is a clique of its own one-skeleton); the counit/adjunction needs the flag
  axiom plus singletons to rebuild a face from its edges.  The two sides of the
  Galois connection are exactly "downward closure" vs. "flagness".
Failure analysis: the adjunction is genuinely conditional — without singletons the
  reverse inclusion fails (see `flag_not_cliqueComplex_without_singletons` in the
  base file), so the connection is an *insertion* only onto the flag complexes.
-- !-- Lab Notebook -- !--
-/
import Mathlib
import Geometry.CliqueComplexFlag

namespace CliqueComplexFlag

open scoped Classical

universe u
variable {V : Type u}

/-! ## Monotonicity of the two functors -/

/-- **The clique complex is monotone in the graph.** A subgraph has fewer cliques. -/
theorem cliqueComplex_mono {G H : SimpleGraph V} (h : G ≤ H) :
    (cliqueComplex G).faces ⊆ (cliqueComplex H).faces := by
  -- !-- a clique of `G` is a clique of any supergraph `H ≥ G`. -- !--
  intro s hs
  rw [mem_cliqueComplex, SimpleGraph.isClique_iff] at hs ⊢
  intro u hu v hv huv
  exact h (hs hu hv huv)

/-- **The one-skeleton is monotone in the complex.** More faces means more edges. -/
theorem oneSkeleton_mono {K L : ASC V} (h : K.faces ⊆ L.faces) :
    oneSkeleton K ≤ oneSkeleton L := by
  -- !-- an edge of `sk K` is a 2-face of `K`, hence a 2-face of `L ⊇ K`. -- !--
  rw [SimpleGraph.le_iff_adj]
  intro u v huv
  rw [oneSkeleton_adj] at huv ⊢
  exact ⟨huv.1, h huv.2⟩

/-! ## The unit of the adjunction -/

/-- **The unit `K ⊆ Δ(sk K)`.** Every face of `K` is a clique of its own
one-skeleton.  Remarkably this needs *only* downward closure, not flagness. -/
theorem le_cliqueComplex_oneSkeleton (K : ASC V) :
    K.faces ⊆ (cliqueComplex (oneSkeleton K)).faces := by
  -- !-- a face `s`: each pair `{u,v} ⊆ s` is a face by downward closure, i.e. an
  --     edge of `sk K`, so `s` is a clique in `sk K`. -- !--
  intro s hs
  rw [mem_cliqueComplex, SimpleGraph.isClique_iff]
  intro u hu v hv huv
  rw [oneSkeleton_adj]
  refine ⟨huv, K.down_closed ?_ hs⟩
  intro x hx
  simp only [Finset.mem_insert, Finset.mem_singleton] at hx
  rcases hx with rfl | rfl
  · exact_mod_cast hu
  · exact_mod_cast hv

/-! ## The closure operator `Δ ∘ sk` -/

/-- **Idempotence / closure law:** `Δ(sk(Δ G)) = Δ G`. The composite `Δ ∘ sk` is a
closure operator, and is the identity on complexes already of the form `Δ G`. -/
theorem cliqueComplex_oneSkeleton_idem (G : SimpleGraph V) :
    cliqueComplex (oneSkeleton (cliqueComplex G)) = cliqueComplex G := by
  -- !-- immediate from `oneSkeleton_cliqueComplex : sk (Δ G) = G`. -- !--
  rw [oneSkeleton_cliqueComplex]

/-! ## The Galois adjunction -/

/-- **The Galois adjunction `Δ G ⊆ K ↔ G ≤ sk K`** for a flag complex `K`
containing all singletons.  This exhibits `Δ ⊣ sk` as a genuine adjunction onto
the flag complexes. -/
theorem cliqueComplex_galois {K : ASC V} (hflag : IsFlag K)
    (hsing : ∀ v : V, ({v} : Finset V) ∈ K.faces) (G : SimpleGraph V) :
    (cliqueComplex G).faces ⊆ K.faces ↔ G ≤ oneSkeleton K := by
  -- !-- (→) an edge `u~v` gives a 2-clique `{u,v} ∈ Δ G ⊆ K`, i.e. an edge of `sk K`.
  --     (←) a clique `s` of `G` has all pairs as edges of `sk K`, hence as faces of
  --     `K`; flagness + singletons rebuild `s` as a face. -- !--
  constructor
  · intro h
    rw [SimpleGraph.le_iff_adj]
    intro u v huv
    rw [oneSkeleton_adj]
    have hne : u ≠ v := G.ne_of_adj huv
    refine ⟨hne, h ?_⟩
    rw [mem_cliqueComplex]
    exact (isClique_pair hne).2 huv
  · intro h s hs
    rw [mem_cliqueComplex, SimpleGraph.isClique_iff] at hs
    refine hflag s (fun u _ => hsing u) ?_
    intro u hu v hv huv
    have hadj : G.Adj u v := hs (by exact_mod_cast hu) (by exact_mod_cast hv) huv
    have : (oneSkeleton K).Adj u v := h hadj
    rw [oneSkeleton_adj] at this
    exact this.2

end CliqueComplexFlag