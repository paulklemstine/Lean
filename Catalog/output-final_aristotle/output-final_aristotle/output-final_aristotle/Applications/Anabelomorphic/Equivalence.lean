/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Anabelomorphic Equivalence — rigidity and degree non-rigidity

We prove the two structural theorems linking the group-isomorphism condition of
`AnabelEquiv` to the arithmetic invariants `(p, f)` of a residue datum.

* `anabelEquiv_iff` (**Main Theorem 1**): the residue tori are isomorphic *iff* the residue
  characteristic and residue degree agree.  This is the precise "group isomorphism condition ⟺
  anabelomorphic equivalence" statement of the mission: an abstract isomorphism of the GL(1) residue
  groups is exactly the equality `p = p'` and `f = f'`.

* `degree_not_rigid` (**Main Theorem 3**, counter-intuitive): the coarser invariant "same residue
  characteristic and same total degree `e·f`" does **not** force anabelomorphic equivalence.  We
  exhibit two local data of the same characteristic `2` and the same degree `2` — namely
  `(e,f) = (1,2)` and `(e,f) = (2,1)` — whose residue tori are *not* isomorphic.  Hence residue
  degree is a strictly finer anabelomorphic invariant than the field degree: the ramification can be
  traded against residue degree while keeping `p` and `[K:ℚ_p]` fixed, yet the abelian Langlands
  datum changes.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (H1) `AnabelEquiv D D' ↔ D.p = D'.p ∧ D.f = D'.f`.  (H2, surprising)
fixing `p` and the total degree `e·f` is *not* enough to pin down the residue torus — anabelomorphy
sees `f`, not `e·f`.

Experiment (Experimenter): H1's forward direction runs `Nat.card`-transport across the `MulEquiv`,
turns `p^f - 1 = p'^f' - 1` into `p^f = p'^f'` by `omega` (both sides `≥ 2`), then invokes the
prime-power injectivity `Prime.pow_inj'`.  The converse substitutes the equalities and uses
reflexivity.  For H2 we test the smallest witnesses `p = 2`, `(e,f) ∈ {(1,2),(2,1)}`: both have
degree `2`, and `2^2 - 1 = 3 ≠ 1 = 2^1 - 1`, so H1 forbids an isomorphism.

Analysis (Analyst): H1 survives as an exact biconditional.  The essential arithmetic engine is
`Prime.pow_inj'`: prime powers are determined by base and exponent, which is *why* the abelian
invariant `(p, f)` is rigid.  A naive attempt to read off `p` and `f` from `p^f - 1` directly fails
(e.g. `2^2-1 = 3` is prime but knowing `3` still needs factoring `3+1 = 2^2`); routing through the
restored value `p^f` is the clean move.  H2 shows the failure mode of the *coarser* degree relation:
`e·f` is symmetric in a way that `f` is not.

Critique (Critic): is H1 trivial?  No — both directions need real content (`Prime.pow_inj'` and
`Nat.card` transport); it is not `rfl`, `simp`, or `decide`.  Is H2 vacuous?  No — it is an explicit
existence statement with concrete non-isomorphic witnesses, and the negation is discharged *via* H1,
not by asserting a false hypothesis.  Corner cases: `f, f' ≠ 0` are needed (else the residue field is
undefined); these are carried in `PrimeDeg`.

Synthesis (PI): anabelomorphic equivalence of the abelian GL(1) datum is exactly equality of
`(p, f)`, and this is strictly stronger than equality of `(p, e·f)` — ramification is invisible to
degree but visible to the residue torus.
-/
import Novelty.Core

namespace Anabel

open scoped Classical

/-- **Main Theorem 1.**  Two residue tori are isomorphic as groups iff their residue characteristic
and residue degree coincide.  This is the group-isomorphism characterisation of residue
anabelomorphic equivalence. -/
theorem anabelEquiv_iff (D D' : PrimeDeg) :
    AnabelEquiv D D' ↔ D.p = D'.p ∧ D.f = D'.f := by
  constructor;
  · intro h;
    -- By definition of AnabelEquiv, we know that the residue tori of D and D' are isomorphic. This implies that their cardinalities are equal.
    have h_card : D.p ^ D.f = D'.p ^ D'.f := by
      obtain ⟨ e ⟩ := h
      have h_card : Nat.card D.residueUnits = Nat.card D'.residueUnits := by
        exact Nat.card_congr e.toEquiv
      have h_card_eq : D.p ^ D.f - 1 = D'.p ^ D'.f - 1 := by
        rw [ ← card_residueUnits D, ← card_residueUnits D', h_card ]
      have h_card_eq' : D.p ^ D.f = D'.p ^ D'.f := by
        rwa [ tsub_left_inj ( Nat.one_le_pow _ _ D.hp.out.pos ) ( Nat.one_le_pow _ _ D'.hp.out.pos ) ] at h_card_eq
      exact h_card_eq';
    exact Nat.Prime.pow_inj' D.hp.out D'.hp.out D.hf D'.hf h_card
  · intro h
    cases D
    cases D'
    simp_all +decide [ AnabelEquiv.refl ]

/-- A **local datum**: a residue datum together with a ramification index `e > 0`.  Its field degree
is `[K : ℚ_p] = e · f`. -/
structure LocalDatum extends PrimeDeg where
  /-- ramification index -/
  e : ℕ
  /-- ramification is positive -/
  he : e ≠ 0

/-- The field degree `[K : ℚ_p] = e · f`. -/
def LocalDatum.degree (D : LocalDatum) : ℕ := D.e * D.f

/-- **Main Theorem 3** (non-rigidity of degree).  There exist two local data with the *same* residue
characteristic and the *same* field degree whose residue tori are **not** isomorphic.  Hence the
abelian Langlands datum is not determined by `(p, [K:ℚ_p])`: ramification can be traded against
residue degree. -/
theorem degree_not_rigid :
    ∃ D D' : LocalDatum,
      D.p = D'.p ∧ D.degree = D'.degree ∧ ¬ AnabelEquiv D.toPrimeDeg D'.toPrimeDeg := by
  refine' ⟨ _, _, _, _, _ ⟩;
  refine' { p := 2, f := 2, hp := ⟨ by norm_num ⟩, hf := by norm_num, e := 1, he := by norm_num };
  refine' { p := 2, f := 1, hp := ⟨ by norm_num ⟩, hf := by norm_num, e := 2, he := by norm_num };
  · rfl;
  · rfl;
  · exact fun h => absurd ( anabelEquiv_iff _ _ |>.1 h ) ( by decide )

end Anabel