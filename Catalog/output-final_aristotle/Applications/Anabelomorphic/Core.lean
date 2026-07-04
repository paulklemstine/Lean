/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Anabelomorphic Equivalence — Core structures (GL(1) / residue side)

This file develops an honest, self-contained *model* of J. Joshi's notion of **anabelomorphy**
(Joshi 2020a) restricted to the abelian / GL(1) part of the local Langlands correspondence, in the
spirit of the geometrization philosophy of Fargues–Scholze 2024.

Background (informal).  For a non-archimedean local field `K` the local Langlands / class field
theory dictionary attaches to the "GL(1) Langlands stack" the group of characters of the residue
field's multiplicative group `k_K^×`, a finite cyclic group of order `q - 1` where `q = p^f` is the
size of the residue field (`p` the residue characteristic, `f` the residue degree).  Two local
fields are *residue-anabelomorphic* when these arithmetic character groups are isomorphic — a
necessary group-isomorphism condition living underneath any topological isomorphism of absolute
Galois groups.

We faithfully model the residue datum by a prime `p`, a residue degree `f > 0`, and the concrete
finite field `GaloisField p f`.  The group `(GaloisField p f)ˣ` is the residue torus, and
`AnabelEquiv` is the assertion that two residue tori are isomorphic as abstract groups.  We prove it
is an equivalence relation, and record the fundamental cardinality `|k^×| = p^f - 1`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the abelian shadow of anabelomorphy — "two local fields whose residue
character groups are isomorphic" — is captured exactly by an isomorphism of the finite cyclic groups
`(GaloisField p f)ˣ`, and this isomorphism should be governed by, and only by, the pair `(p, f)`.

Experiment (Experimenter): `(GaloisField p f)ˣ` is a finite group; `Fintype.card_units` plus
`GaloisField.card` give `|k^×| = p^f - 1` in four lines.  `AnabelEquiv` is `Nonempty (· ≃* ·)`,
whose reflexivity/symmetry/transitivity are `MulEquiv.refl/​symm/​trans`.

Analysis (Analyst): bundling the prime into a `PrimeDeg` structure (with the `Fact p.Prime` instance
attached) is what makes `GaloisField D.p D.f` typecheck uniformly, so the equivalence relation can be
stated over the *bundled* residue data rather than over loose `(p, f)` tuples.

Critique (Critic): `AnabelEquiv` is a genuine group-theoretic relation, not a definitional rename —
the hard content (that it forces `p = p'` and `f = f'`) is proved in `Equivalence.lean`, and the
non-obvious counting in `LanglandsCount.lean`.  Nothing here is vacuous: `card_residueUnits`
genuinely needs finiteness of the Galois field.

Synthesis (PI): a bundled residue datum with an equivalence relation `AnabelEquiv` and the base
cardinality `p^f - 1` — the foundation on which the rigidity and counting theorems are built.
-/
import Mathlib

namespace Anabel

open scoped Classical

/-- A **residue datum**: a residue characteristic `p` (prime) together with a residue degree
`f > 0`.  It packages the `Fact p.Prime` instance so that `GaloisField p f` typechecks. -/
structure PrimeDeg where
  /-- residue characteristic -/
  p : ℕ
  /-- residue degree `[k_K : 𝔽_p]` -/
  f : ℕ
  /-- `p` is prime -/
  hp : Fact p.Prime
  /-- the residue degree is positive -/
  hf : f ≠ 0

attribute [instance] PrimeDeg.hp

/-- The **residue torus** of a residue datum: the multiplicative group of its residue field
`k_K = GaloisField p f`.  Under local class field theory its character group is the GL(1)
Langlands stack of unramified/​tame characters. -/
abbrev PrimeDeg.residueUnits (D : PrimeDeg) : Type := (GaloisField D.p D.f)ˣ

/-- The order of the residue field `q = p^f`. -/
def PrimeDeg.residueCard (D : PrimeDeg) : ℕ := D.p ^ D.f

/-- **Residue-anabelomorphic equivalence**: the residue tori are isomorphic as abstract groups.
This is the abelian / GL(1) shadow of Joshi's anabelomorphy. -/
def AnabelEquiv (D D' : PrimeDeg) : Prop :=
  Nonempty (D.residueUnits ≃* D'.residueUnits)

/-- The residue torus is finite of order `p^f - 1`. -/
lemma card_residueUnits (D : PrimeDeg) :
    Nat.card D.residueUnits = D.p ^ D.f - 1 := by
  haveI : Fintype (GaloisField D.p D.f) := Fintype.ofFinite _
  simp only [PrimeDeg.residueUnits]
  rw [Nat.card_eq_fintype_card, Fintype.card_units, ← Nat.card_eq_fintype_card,
    GaloisField.card D.p D.f D.hf]

@[refl]
lemma AnabelEquiv.refl (D : PrimeDeg) : AnabelEquiv D D := ⟨MulEquiv.refl _⟩

lemma AnabelEquiv.symm {D D' : PrimeDeg} (h : AnabelEquiv D D') : AnabelEquiv D' D :=
  h.elim fun e => ⟨e.symm⟩

lemma AnabelEquiv.trans {D D' D'' : PrimeDeg}
    (h : AnabelEquiv D D') (h' : AnabelEquiv D' D'') : AnabelEquiv D D'' :=
  h.elim fun e => h'.elim fun e' => ⟨e.trans e'⟩

/-- `AnabelEquiv` is an equivalence relation on residue data. -/
lemma anabelEquiv_equivalence : Equivalence AnabelEquiv :=
  ⟨AnabelEquiv.refl, AnabelEquiv.symm, AnabelEquiv.trans⟩

end Anabel