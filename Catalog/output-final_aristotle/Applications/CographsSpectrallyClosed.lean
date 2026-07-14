import Mathlib

/-!
# Cographs form a self-complementary hereditary class

A *cograph* is a graph containing no induced path on four vertices `P₄`.
Cographs arise as exactly the graphs generated from the single vertex by the
operations of disjoint union and join, and they are central to the study of
*generalized spectral characterizations*: a graph `H` is *generalized cospectral*
with `G` when `G` and `H` share both their adjacency spectrum and the spectrum of
their complements.  The reason the complement spectrum is the natural companion
invariant for the cograph class is a structural fact proved here:

* `isCograph_compl_iff` — **a graph is a cograph if and only if its complement is
  a cograph.**  Equivalently, the class of cographs is closed under
  complementation; it is a *self-complementary* graph class.

The proof rests on two ingredients that are of independent interest:

* `complEmb` — an *induced* embedding `G ↪g H` induces an induced embedding of the
  complements `Gᶜ ↪g Hᶜ`.  Thus taking complements is functorial on induced
  subgraphs, and forbidden-induced-subgraph classes transport across complements.
* `p4selfcompl` — the path `P₄` is **self-complementary**: `P₄ ≅ P₄ᶜ`, realised by
  the explicit vertex permutation `0 1 2 3 ↦ 1 3 0 2`.

Because forbidding `P₄` is a self-complementary condition, the entire cograph class
is self-complementary.  We also record the *hereditary* property
(`isCograph_of_embedding`): an induced subgraph of a cograph is again a cograph.

Finally we set up the spectral vocabulary.  The identity
`adjMatrix_compl_eq` expresses the complement adjacency matrix as
`A(Gᶜ) = J - I - A(G)`, the algebraic bridge that ties the complement spectrum to
the adjacency spectrum, and `GenCospectral` packages the two-spectrum invariant.

## Lab Notes

`-- !-- Lab Notes -- !--`

**Hypothesis.**  The generalized-spectral closure of the cograph class should
ultimately reduce to a self-complementary structural characterization: since
`P₄` is self-complementary, forbidding it is a condition invariant under the
complement operation, and generalized cospectrality (which pairs the adjacency and
complement spectra) is precisely the invariant that respects this symmetry.

**Experiment.**  We formalized induced subgraph embeddings via
`SimpleGraph.Embedding` (the relation embedding of adjacency, which is induced in
both directions).  The complement functor `complEmb` was built by transporting the
underlying vertex embedding and checking the `≠ ∧ ¬Adj` clause of complement
adjacency.  Self-complementarity of `P₄` was obtained by exhibiting the explicit
permutation `![1,3,0,2]` and verifying it is a graph isomorphism by finite case
analysis.

**Analysis.**  The two ingredients compose cleanly: an induced `P₄` in `G`
complements to an induced `P₄` in `Gᶜ` (after relabeling via self-complementarity),
giving `isCograph_compl_iff`.  The hereditary property follows from composition of
embeddings.  The algebraic identity `A(Gᶜ) = J - I - A(G)` survived an entrywise
case split; it is the mechanism by which the complement spectrum is *not*
independent of the adjacency spectrum.

**Critique.**  The main theorem is not vacuous: it constructs a genuine
complement functor and an explicit isomorphism, and it uses `by_contra`-style
negation transport (`not_iff_not`) rather than `simp`/`decide` alone.  A hidden
corner case — whether the complement decidability instances interfere with rewrites
— was avoided by phrasing `GenCospectral` without rewriting under the complement.

**Synthesis.**  Cographs are a self-complementary hereditary class; this is the
structural backbone that makes the complement spectrum the correct extra invariant
for a generalized spectral characterization of cographs.
-/

open SimpleGraph

namespace CographSpectral

variable {V : Type*}

/-- The complement functor on induced embeddings: an induced embedding `G ↪g H`
transports to an induced embedding of complements `Gᶜ ↪g Hᶜ`, using the same
underlying vertex map. -/
def complEmb {V W : Type*} {G : SimpleGraph V} {H : SimpleGraph W} (f : G ↪g H) :
    Gᶜ ↪g Hᶜ where
  toEmbedding := f.toEmbedding
  map_rel_iff' := by
    intro a b
    simp only [compl_adj]
    constructor
    · rintro ⟨hne, hnadj⟩
      exact ⟨fun h => hne (by rw [h]), fun hadj => hnadj (f.map_adj_iff.mpr hadj)⟩
    · rintro ⟨hne, hnadj⟩
      exact ⟨fun h => hne (f.injective h), fun hadj => hnadj (f.map_adj_iff.mp hadj)⟩

/-- The vertex relabeling `0 1 2 3 ↦ 1 3 0 2` that witnesses self-complementarity
of the path `P₄`. -/
def sigma4 : Fin 4 ≃ Fin 4 where
  toFun := ![1, 3, 0, 2]
  invFun := ![2, 0, 3, 1]
  left_inv := by decide
  right_inv := by decide

/-- **The path `P₄` is self-complementary.**  The permutation `sigma4` is a graph
isomorphism from `P₄` to its complement. -/
def p4selfcompl : pathGraph 4 ≃g (pathGraph 4)ᶜ where
  toEquiv := sigma4
  map_rel_iff' := by
    intro a b
    fin_cases a <;> fin_cases b <;> simp [sigma4, pathGraph_adj, compl_adj]

/-- A graph is a *cograph* when it has no induced path on four vertices `P₄`. -/
def IsCograph (G : SimpleGraph V) : Prop := IsEmpty (pathGraph 4 ↪g G)

/-- If `G` contains an induced `P₄`, then so does its complement: complement the
embedding and relabel by self-complementarity of `P₄`. -/
theorem nonempty_p4_compl {G : SimpleGraph V} (h : Nonempty (pathGraph 4 ↪g G)) :
    Nonempty (pathGraph 4 ↪g Gᶜ) := by
  obtain ⟨e⟩ := h
  exact ⟨(complEmb e).comp p4selfcompl.toEmbedding⟩

/-- An induced `P₄` in `G` and an induced `P₄` in `Gᶜ` occur together. -/
theorem nonempty_p4_iff_compl {G : SimpleGraph V} :
    Nonempty (pathGraph 4 ↪g G) ↔ Nonempty (pathGraph 4 ↪g Gᶜ) := by
  refine ⟨nonempty_p4_compl, fun h => ?_⟩
  have := nonempty_p4_compl h
  rwa [compl_compl] at this

/-- **Cographs are closed under complementation.**  A graph is a cograph if and
only if its complement is a cograph, so the cograph class is self-complementary.
This is the structural reason that the complement spectrum is the natural companion
invariant in a generalized spectral characterization of cographs. -/
theorem isCograph_compl_iff {G : SimpleGraph V} : IsCograph G ↔ IsCograph Gᶜ := by
  rw [IsCograph, IsCograph, ← not_nonempty_iff, ← not_nonempty_iff, not_iff_not]
  exact nonempty_p4_iff_compl

/-- **Cographs are a hereditary class.**  Any graph that embeds as an induced
subgraph of a cograph is itself a cograph. -/
theorem isCograph_of_embedding {W : Type*} {G : SimpleGraph V} {H : SimpleGraph W}
    (f : G ↪g H) (hH : IsCograph H) : IsCograph G := by
  rw [IsCograph, isEmpty_iff] at *
  exact fun e => hH (f.comp e)

/-- **The cograph property is an isomorphism invariant.**  Isomorphic graphs are
cographs together, so "being a cograph" is a genuine graph invariant (and in
particular a candidate for a spectral characterization). -/
theorem isCograph_congr {W : Type*} {G : SimpleGraph V} {H : SimpleGraph W}
    (e : G ≃g H) : IsCograph G ↔ IsCograph H :=
  ⟨fun hG => isCograph_of_embedding e.symm.toEmbedding hG,
   fun hH => isCograph_of_embedding e.toEmbedding hH⟩

/-- **Complement adjacency identity.**  Over any field, the adjacency matrix of the
complement satisfies `A(Gᶜ) = J - I - A(G)`, where `J` is the all-ones matrix and
`I` the identity.  This linear relation is the algebraic bridge that couples the
complement spectrum to the adjacency spectrum. -/
theorem adjMatrix_compl_eq [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] [DecidableRel Gᶜ.Adj] :
    (Gᶜ.adjMatrix ℚ) = Matrix.of (fun _ _ => (1 : ℚ)) - 1 - G.adjMatrix ℚ := by
  ext v w
  simp only [adjMatrix_apply, Matrix.sub_apply, Matrix.of_apply, Matrix.one_apply, compl_adj]
  by_cases hvw : v = w
  · subst hvw; simp [SimpleGraph.irrefl]
  · by_cases hadj : G.Adj v w <;> simp [hvw, hadj]

/-- Two graphs on a common finite vertex set are *generalized cospectral* when they
share the characteristic polynomial of their adjacency matrix **and** the
characteristic polynomial of the adjacency matrix of their complement. -/
noncomputable def GenCospectral [Fintype V] [DecidableEq V]
    (G H : SimpleGraph V) [DecidableRel G.Adj] [DecidableRel H.Adj]
    [DecidableRel Gᶜ.Adj] [DecidableRel Hᶜ.Adj] : Prop :=
  (G.adjMatrix ℚ).charpoly = (H.adjMatrix ℚ).charpoly ∧
    (Gᶜ.adjMatrix ℚ).charpoly = (Hᶜ.adjMatrix ℚ).charpoly

/-- Generalized cospectrality is a symmetric relation. -/
theorem genCospectral_symm [Fintype V] [DecidableEq V]
    {G H : SimpleGraph V} [DecidableRel G.Adj] [DecidableRel H.Adj]
    [DecidableRel Gᶜ.Adj] [DecidableRel Hᶜ.Adj]
    (h : GenCospectral G H) : GenCospectral H G :=
  ⟨h.1.symm, h.2.symm⟩

/-- Generalized cospectrality is reflexive. -/
theorem genCospectral_refl [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] [DecidableRel Gᶜ.Adj] :
    GenCospectral G G :=
  ⟨rfl, rfl⟩

/-- **The two-spectrum invariant is closed under complementation.**  If `G` and
`H` are generalized cospectral, then so are their complements `Gᶜ` and `Hᶜ`.  This
is the algebraic counterpart of `isCograph_compl_iff`: complementation acts on the
invariant simply by swapping its two components, which is exactly why the pair
(adjacency spectrum, complement spectrum) is the right invariant for a
self-complementary class such as cographs. -/
theorem genCospectral_compl [Fintype V] [DecidableEq V]
    {G H : SimpleGraph V} [DecidableRel G.Adj] [DecidableRel H.Adj]
    [DecidableRel Gᶜ.Adj] [DecidableRel Hᶜ.Adj]
    (h : GenCospectral G H) : GenCospectral Gᶜ Hᶜ := by
  refine ⟨h.2, ?_⟩
  have hG : Gᶜᶜ.adjMatrix ℚ = G.adjMatrix ℚ := by congr 1; exact compl_compl G
  have hH : Hᶜᶜ.adjMatrix ℚ = H.adjMatrix ℚ := by congr 1; exact compl_compl H
  rw [hG, hH]; exact h.1

end CographSpectral