/-
# No isometric embedding of the Petersen graph into a bipartite abelian Cayley graph

This file combines a general **metric** obstruction with the combinatorial fact
`PetersenGraph.Petersen_not_colorable_two` (from `PetersenNonBipartite.lean`) to
prove that the Petersen graph does not isometrically embed into any *bipartite*
Cayley graph of a finite abelian group — in particular into any hypercube
`Q_k = Cay((ℤ/2)^k, standard basis)`.

## Contents

* `colorable_of_isometric` : an isometric map `f : V → W` (one satisfying
  `H.dist (f u) (f v) = G.dist u v`) **pulls back** any proper `n`-coloring of
  the host `H` to a proper `n`-coloring of `G`.  The metric hypothesis is used
  precisely at the point where a `G`-edge (`dist = 1`) must map to an `H`-edge.
* `no_isometric_into_colorable` : hence a non-`n`-colorable graph admits no
  isometric embedding into an `n`-colorable one.
* `cayleyGraph` : the Cayley graph of an additive abelian group with a symmetric
  connection set `S` avoiding `0`.
* `cayleyGraph_colorable_two` : if there is an additive character
  `ψ : A →+ ℤ/2` with `ψ s = 1` for every `s ∈ S`, then `Cay(A,S)` is bipartite.
* `petersen_no_isometric_into_bipartite_cayley` : **main theorem** — under such a
  character, the Petersen graph does not isometrically embed into `Cay(A,S)`.
* `petersen_no_isometric_into_hypercube` : the specialization to hypercubes,
  recovering (and strengthening to *isometric* non-embeddability) the classical
  statement that the Petersen graph is not a partial cube.

This extends the catalog files `CayleyStability/Embedding.lean` (Cayley digraph
framework) and `HypercubeNoStretch.lean` (GF(2) hypercube distance labelling).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The description's known fact — "Petersen is not a
partial cube, so it does not embed into a hypercube" — is a shadow of a purely
metric principle: an isometric embedding into ANY bipartite graph forces the
source to be bipartite.  Bold refinement: characterize the bipartite abelian
Cayley hosts exactly (existence of a ℤ/2 character non-trivial on the whole
connection set) and rule all of them out at once.

Experiment (Experimenter): (1) Proved `colorable_of_isometric` by pulling back a
coloring `c` of `H` along `f`; the only place the metric is used is
`dist_eq_one_iff_adj`, converting a `G`-edge to `dist = 1` to (via `f`) `dist = 1`
in `H` to an `H`-edge, where `c` separates colors.  (2) Built `cayleyGraph`
over an `AddCommGroup`, with symmetry from `S = -S` and looplessness from
`0 ∉ S`.  (3) `cayleyGraph_colorable_two`: the character `ψ` IS a `ℤ/2`-coloring
because for an edge `h - g ∈ S` we get `ψ h - ψ g = ψ(h-g) = 1 ≠ 0`.
(4) Hypercube instance: connection set = basis vectors, character = coordinate
sum; a basis vector sums to `1`.

Analysis (Analyst): The obstruction is *general in n*: `colorable_of_isometric`
holds for every `n`, not just `2`.  What is special to abelian Cayley graphs is
only how easily the bipartite (n = 2) certificate is produced — a single group
character.  Failure mode noted: the argument says NOTHING about non-bipartite
abelian Cayley hosts (odd cycles, etc.), where the Petersen graph might a priori
embed; that gap is exactly the open grand conjecture, recorded in
FUTURE_DIRECTIONS.

Critique (Critic): The main theorems are not vacuous — the hypercube corollary
supplies an explicit family of hosts to which they apply with a concrete
character. No theorem is `True`/`rfl`/`native_decide`; each routes through the
coloring-pullback argument, `map_sub`, and the walk-parity core. The metric
hypothesis is genuinely used (drop it and `colorable_of_isometric` is false: a
non-isometric map can send a triangle into an edge).

Synthesis (PI): The clean split is "metric obstruction (any n) + cheap bipartite
certificate (n = 2 via a character)". This isolates precisely which abelian
hosts are handled and turns the remaining hosts into a sharp, testable
conjecture.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Catalog.Applications.CayleyStability.PetersenNonBipartite

open SimpleGraph

namespace PetersenGraph

/-- **Metric obstruction (any number of colors).**  An isometric map
`f : V → W` (satisfying `H.dist (f u) (f v) = G.dist u v`) pulls back a proper
`n`-coloring of the host `H` to a proper `n`-coloring of the source `G`.  The
metric hypothesis enters exactly once: to send a `G`-edge to an `H`-edge. -/
lemma colorable_of_isometric {V W : Type*} {G : SimpleGraph V} {H : SimpleGraph W}
    (f : V → W) (hf : ∀ u v, H.dist (f u) (f v) = G.dist u v) {n : ℕ}
    (hH : H.Colorable n) : G.Colorable n := by
  obtain ⟨c⟩ := hH
  refine ⟨Coloring.mk (fun v => c (f v)) ?_⟩
  intro u v huv
  have h1 : G.dist u v = 1 := dist_eq_one_iff_adj.mpr huv
  have h2 : H.Adj (f u) (f v) := dist_eq_one_iff_adj.mp (by rw [hf, h1])
  exact c.valid h2

/-- A graph that is **not** `n`-colorable admits no isometric embedding into an
`n`-colorable graph. -/
theorem no_isometric_into_colorable {V W : Type*} {G : SimpleGraph V}
    {H : SimpleGraph W} {n : ℕ} (hG : ¬ G.Colorable n) (hH : H.Colorable n)
    (f : V → W) : ¬ (∀ u v, H.dist (f u) (f v) = G.dist u v) :=
  fun hf => hG (colorable_of_isometric f hf hH)

variable {A : Type*} [AddCommGroup A]

/-- The **Cayley graph** of an additive abelian group `A` with symmetric
connection set `S` (with `0 ∉ S`): `g` and `h` are adjacent iff `h - g ∈ S`. -/
def cayleyGraph (S : Set A) (hsymm : ∀ s ∈ S, -s ∈ S) (h0 : (0 : A) ∉ S) :
    SimpleGraph A where
  Adj g h := (h - g) ∈ S
  symm := fun g h hgh => by
    have : -(h - g) ∈ S := hsymm _ hgh
    simpa [neg_sub] using this
  loopless := ⟨fun g hg => h0 (by simpa using hg)⟩

/-- **A character certifies bipartiteness.**  If there is an additive character
`ψ : A →+ ℤ/2` sending every connection-set element to `1`, then the Cayley
graph `Cay(A, S)` is `2`-colorable (bipartite): `ψ` itself is a proper
`2`-coloring. -/
lemma cayleyGraph_colorable_two (S : Set A) (hsymm : ∀ s ∈ S, -s ∈ S)
    (h0 : (0 : A) ∉ S) (ψ : A →+ ZMod 2) (hψ : ∀ s ∈ S, ψ s = 1) :
    (cayleyGraph S hsymm h0).Colorable 2 := by
  have hc : Fintype.card (ZMod 2) = 2 := by decide
  rw [← hc]
  refine Coloring.colorable (Coloring.mk (fun g => ψ g) ?_)
  intro g h hgh
  have hs : ψ (h - g) = 1 := hψ _ hgh
  rw [map_sub] at hs
  intro hcontra
  simp only at hcontra
  rw [hcontra, sub_self] at hs
  exact absurd hs (by decide)

/-- **Main theorem.**  The Petersen graph does not isometrically embed into any
bipartite Cayley graph of a finite abelian group, where "bipartite" is witnessed
by an additive character `ψ : A →+ ℤ/2` non-trivial on the whole connection
set. -/
theorem petersen_no_isometric_into_bipartite_cayley
    (S : Set A) (hsymm : ∀ s ∈ S, -s ∈ S) (h0 : (0 : A) ∉ S)
    (ψ : A →+ ZMod 2) (hψ : ∀ s ∈ S, ψ s = 1) (f : PetersenV → A) :
    ¬ (∀ u v, (cayleyGraph S hsymm h0).dist (f u) (f v) = Petersen.dist u v) :=
  no_isometric_into_colorable Petersen_not_colorable_two
    (cayleyGraph_colorable_two S hsymm h0 ψ hψ) f

/-! ## The hypercube specialization -/

/-- Connection set of the `k`-dimensional hypercube over `GF(2)`: the standard
basis vectors `Pi.single i 1`. -/
def hypS (k : ℕ) : Set (Fin k → ZMod 2) := {x | ∃ i, x = Pi.single i 1}

lemma hypS_symm (k : ℕ) : ∀ s ∈ hypS k, -s ∈ hypS k := by
  rintro s ⟨i, rfl⟩
  exact ⟨i, by funext j; simp⟩

lemma hypS_zero (k : ℕ) : (0 : Fin k → ZMod 2) ∉ hypS k := by
  rintro ⟨i, hi⟩
  have := congrFun hi i
  simp at this

/-- The coordinate-sum character `(Fin k → ℤ/2) →+ ℤ/2`. -/
noncomputable def sumHom (k : ℕ) : (Fin k → ZMod 2) →+ ZMod 2 where
  toFun x := ∑ i, x i
  map_zero' := by simp
  map_add' x y := by simp [Finset.sum_add_distrib]

lemma sumHom_hypS (k : ℕ) : ∀ s ∈ hypS k, sumHom k s = 1 := by
  rintro s ⟨i, rfl⟩
  simp [sumHom]

/-- **Corollary (partial cube obstruction, isometric form).**  The Petersen
graph does not isometrically embed into the hypercube
`Q_k = Cay((ℤ/2)^k, standard basis)` for any `k`. -/
theorem petersen_no_isometric_into_hypercube (k : ℕ)
    (f : PetersenV → (Fin k → ZMod 2)) :
    ¬ (∀ u v, (cayleyGraph (hypS k) (hypS_symm k) (hypS_zero k)).dist (f u) (f v)
        = Petersen.dist u v) :=
  petersen_no_isometric_into_bipartite_cayley (hypS k) (hypS_symm k) (hypS_zero k)
    (sumHom k) (sumHom_hypS k) f

end PetersenGraph