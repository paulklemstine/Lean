import Geometry.CorpusBettiExtremal

/-!
# Semantic labels are not recoverable from corpus topology

The research thread conjectures that research-community labels, if defined independently of
the citation data, cannot be recovered from homology alone by any *uniformly stable* rule.
This file proves the exact version of that statement, with the stability requirement made
precise as **equivariance under renaming of theorems**.

A recovery rule is a map `R : Corpus V → V → L` assigning a community label to each theorem.
Rule `R` is `Uniform` if renaming the theorems renames the output correspondingly: this is
what it means for the rule to use only the incidence pattern, and not the identity or any
metadata of individual theorems.  A corpus is `VertexTransitive` if some renaming carrying
any prescribed theorem to any other leaves the corpus unchanged.

**Theorem (`no_uniform_recovery`).** On a vertex-transitive corpus, every uniform rule
outputs a *constant* labelling; hence it disagrees with every non-constant ground-truth
labelling.  No amount of topological information helps, because the obstruction is the
symmetry of the incidence pattern itself.

The witness is the corpus family already studied in `CorpusBettiExtremal`: the complete
`d`-uniform design is vertex-transitive, and for `d = 2` on `n = m + 1 ≥ 3` theorems its
first Betti number is `C(m, 2) > 0` (`design_betti_one_pos`).  So the counterexample is not
a homologically trivial degenerate object: it has as much first homology as the ceiling
permits, and the labels are still invisible.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (1) uniformity (equivariance under renaming) alone already
obstructs label recovery on symmetric corpora; (2) the obstruction is unrelated to how much
homology the corpus carries; (3) the extremal corpora of the previous file are exactly the
hardest instances, since maximal symmetry and maximal homology coincide there; (4) recovery
becomes possible only if the rule may read data that is not renaming-invariant, i.e. vertex
metadata.

Experiment (Experimenter): the design corpora `skeletonCorpus V d` were tested for renaming
invariance.  Applying an arbitrary permutation to every document permutes the family of all
`d`-sets onto itself, so the corpus is fixed by the whole symmetric group; transpositions
then give transitivity.  For `d = 2`, `n = 3, 4, 5` the first Betti number of the realised
profile is `C(n-1, 2) = 1, 3, 6`, all nonzero.

Analysis (Analyst): hypotheses (1)-(3) survive as theorems.  Hypothesis (4) is a definitional
observation rather than a theorem: dropping uniformity makes the statement false, since the
constant-output rule `fun _ => ℓ` recovers `ℓ`, which is precisely the content of "metadata
is needed".  The failure is therefore not a limitation of homology but of any invariant of
the incidence structure whatsoever.

Critique (Critic): the theorem is about deterministic exact recovery; it does not by itself
rule out approximate or probabilistic recovery under a generative assortativity assumption,
which is exactly the escape route the thread proposes.  It also uses full equivariance;
a rule equivariant only under automorphisms of the given corpus satisfies the same proof, so
the hypothesis is not stronger than necessary.

Synthesis (Principal Investigator): a cycle is an incidence pattern, not a semantic object.
Formally: symmetry of the incidence pattern is a hard obstruction to identifiability, and
the extremal-homology corpora are the extremal counterexamples.
-- !-- end Lab Notes -- !--
-/

noncomputable section

open Classical Finset
open TheoremNetworkTopology CorpusBettiExtremal

namespace CorpusLabelIdentifiability

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Renaming theorems -/

/-- Renaming the theorems of a corpus by a permutation `σ`. -/
def relabel (σ : Equiv.Perm V) (C : Corpus V) : Corpus V :=
  C.image fun W => W.image σ

/-- A recovery rule is *uniform* when renaming the theorems renames its output
correspondingly: the rule reads the incidence pattern only. -/
def Uniform {L : Type*} (R : Corpus V → V → L) : Prop :=
  ∀ (σ : Equiv.Perm V) (C : Corpus V) (v : V), R (relabel σ C) (σ v) = R C v

/-- A corpus is *vertex-transitive* when any theorem can be carried to any other by a
renaming that leaves the corpus unchanged. -/
def VertexTransitive (C : Corpus V) : Prop :=
  ∀ x y : V, ∃ σ : Equiv.Perm V, relabel σ C = C ∧ σ x = y

/-! ## The obstruction -/

omit [Fintype V] in
/-- On a vertex-transitive corpus every uniform rule is constant. -/
theorem constant_of_uniform_of_vertexTransitive {L : Type*} (R : Corpus V → V → L)
    (hR : Uniform R) {C : Corpus V} (hC : VertexTransitive C) (x y : V) :
    R C x = R C y := by
  obtain ⟨σ, hσC, hσx⟩ := hC x y
  have h := hR σ C x
  rw [hσC, hσx] at h
  exact h.symm

omit [Fintype V] in
/-- **Non-identifiability.**  No uniform rule can output a non-constant labelling on a
vertex-transitive corpus, so no uniform rule recovers a ground-truth labelling that
distinguishes any two theorems. -/
theorem no_uniform_recovery {L : Type*} (R : Corpus V → V → L) (hR : Uniform R)
    {C : Corpus V} (hC : VertexTransitive C) (lab : V → L) {x y : V}
    (hxy : lab x ≠ lab y) : R C ≠ lab := by
  intro h
  refine hxy ?_
  rw [← h]
  exact constant_of_uniform_of_vertexTransitive R hR hC x y

/-! ## The design corpus is a maximally symmetric witness -/

/-- The family of all `d`-element documents is invariant under every renaming. -/
theorem relabel_skeletonCorpus (σ : Equiv.Perm V) (d : ℕ) :
    relabel σ (skeletonCorpus V d) = skeletonCorpus V d := by
  ext T
  simp only [relabel, skeletonCorpus, Finset.mem_image, Finset.mem_powersetCard]
  constructor
  · rintro ⟨W, ⟨-, hWcard⟩, rfl⟩
    exact ⟨Finset.subset_univ _,
      by rw [Finset.card_image_of_injective _ σ.injective, hWcard]⟩
  · rintro ⟨-, hTcard⟩
    refine ⟨T.image σ.symm, ⟨Finset.subset_univ _, ?_⟩, ?_⟩
    · rw [Finset.card_image_of_injective _ σ.symm.injective, hTcard]
    · rw [Finset.image_image]
      simp

theorem vertexTransitive_skeletonCorpus (d : ℕ) :
    VertexTransitive (skeletonCorpus V d) := fun x y =>
  ⟨Equiv.swap x y, relabel_skeletonCorpus _ d, Equiv.swap_apply_left x y⟩

/-- **Labels are invisible on the extremal corpora.**  For every document size `d`, no
uniform rule recovers any labelling of the theorems that distinguishes two of them from the
complete `d`-uniform design. -/
theorem no_uniform_recovery_design {L : Type*} (R : Corpus V → V → L) (hR : Uniform R)
    (d : ℕ) (lab : V → L) {x y : V} (hxy : lab x ≠ lab y) :
    R (skeletonCorpus V d) ≠ lab :=
  no_uniform_recovery R hR (vertexTransitive_skeletonCorpus d) lab hxy

/-- The witness is homologically rich: the realised profile of the `2`-uniform design on
`n = m + 1` theorems has first Betti number `C(m, 2)`. -/
theorem design_betti_one {m : ℕ} (hcard : Fintype.card V = m + 1) (hdn : 2 ≤ m + 1) :
    (skeletonHomologyProfile hcard (by norm_num) hdn).beta 1 = m.choose 2 := by
  simp [skeletonHomologyProfile, skeletonBetti]

/-- ... and that first Betti number is positive as soon as there are at least three
theorems, so the non-identifiability above is not an artefact of a topologically trivial
example. -/
theorem design_betti_one_pos {m : ℕ} (hcard : Fintype.card V = m + 1) (hm : 2 ≤ m) :
    0 < (skeletonHomologyProfile hcard (by norm_num) (by omega : 2 ≤ m + 1)).beta 1 := by
  rw [design_betti_one hcard (by omega)]
  exact Nat.choose_pos hm

omit [Fintype V] in
/-- **Metadata is genuine extra information.**  A rule that does recover a labelling
distinguishing two theorems on a vertex-transitive corpus — for instance the rule that
simply reads the metadata, `fun _ => lab` — is provably *not* uniform.  So uniformity is
exactly the hypothesis carrying the impossibility, and vertex metadata cannot be a
repackaging of the incidence data. -/
theorem not_uniform_of_recovers {L : Type*} (R : Corpus V → V → L)
    {C : Corpus V} (hC : VertexTransitive C) (lab : V → L) {x y : V}
    (hxy : lab x ≠ lab y) (hrec : R C = lab) : ¬ Uniform R := by
  intro hR
  exact no_uniform_recovery R hR hC lab hxy hrec

end CorpusLabelIdentifiability