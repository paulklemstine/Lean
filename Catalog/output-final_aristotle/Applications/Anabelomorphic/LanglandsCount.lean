/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Anabelomorphic Equivalence — the GL(1) Langlands character count

The "GL(1) Langlands stack" over the residue field attaches to a residue datum the character group
of its residue torus `k^×`.  Since `k^×` is a finite cyclic group, it is (non-canonically) its own
Pontryagin dual, so the number of characters of order dividing `m` equals the number of elements
`a ∈ k^×` with `a^m = 1`.  We prove this count is exactly `gcd(m, q - 1)` with `q = p^f` — the
number of `m`-torsion points of the residue torus, equivalently the number of tame characters of
order dividing `m`.  This count is manifestly an anabelomorphic invariant: it depends only on the
residue cardinality `q`, which by `anabelEquiv_iff` is preserved by anabelomorphic equivalence.

* `cyclic_torsion_count`: in any finite cyclic group, `#{a | a^m = 1} = gcd(m, |G|)`.
* `residue_char_count` (**Main Theorem 2**): `#{a ∈ k^× | a^m = 1} = gcd(m, p^f - 1)`.
* `char_count_anabel_invariant`: anabelomorphically equivalent data have equal counts, for every `m`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the number of tame GL(1) characters of order dividing `m` is
`gcd(m, q - 1)`, and is an anabelomorphic invariant.

Experiment (Experimenter): the count in an abstract finite cyclic group reduces, via
`pow_gcd_card_eq_one_iff`, to counting `d`-torsion with `d = gcd(m, |G|) ∣ |G|`; the divisor-sum
identity `sum_card_orderOf_eq_card_pow_eq_one` together with `IsCyclic.card_orderOf_eq_totient` and
`Nat.sum_totient` collapses this to exactly `d`.  Specialising to `(GaloisField p f)ˣ` (cyclic, of
order `p^f - 1`) yields the residue count.

Analysis (Analyst): the decisive simplification is `pow_gcd_card_eq_one_iff` — it lets us replace the
arbitrary exponent `m` by a *divisor* of the group order, after which totient bookkeeping is exact.
Without it one is stuck with the mere inequality `IsCyclic.card_pow_eq_one_le`.

Critique (Critic): the theorem is not `decide`/`native_decide` — it holds for symbolic `p, f, m`,
so it must be proved by genuine counting, using cyclicity of finite-field units.  It is not vacuous:
for `m = q - 1` it returns the full order `q - 1`.  The invariance corollary uses `anabelEquiv_iff`
from the sibling file, so the count genuinely depends on the anabelomorphic structure.

Synthesis (PI): the GL(1) Langlands character count is `gcd(m, q-1)`, an anabelomorphic invariant —
the "stacky point count" attached to the residue datum.
-/
import Applications.Anabelomorphic.Equivalence

namespace Anabel

open scoped Classical
open Finset

/-- In a finite cyclic group, the number of solutions of `a ^ m = 1` is `gcd(m, |G|)`
(valid for every `m`, including `m = 0`, where both sides equal `|G|`). -/
lemma cyclic_torsion_count {α : Type*} [Group α] [Finite α] [IsCyclic α] (m : ℕ) :
    Nat.card {a : α // a ^ m = 1} = Nat.gcd m (Nat.card α) := by
  have h_card_eq : Nat.card {a : α | a ^ m = 1} = Nat.gcd m (Nat.card α) := by
    have h_card_eq : ∀ d : ℕ, d ∣ Nat.card α → Nat.card {a : α | a ^ d = 1} = d := by
      intro d hd; haveI := Fintype.ofFinite α; simp_all +decide ;
      have h_card_eq : ∑ m ∈ Nat.divisors d, (Nat.card {a : α | orderOf a = m}) = d := by
        convert Nat.sum_totient d using 1;
        refine' Finset.sum_congr rfl fun x hx => _;
        convert IsCyclic.card_orderOf_eq_totient ( show x ∣ Fintype.card α from dvd_trans ( Nat.dvd_of_mem_divisors hx ) hd ) using 1;
        simp +decide [ Fintype.card_subtype ];
      convert h_card_eq using 1;
      simp +decide [ Fintype.card_subtype, Nat.card_eq_fintype_card ];
      rw [ ← Finset.card_biUnion ];
      · congr with x ; simp +decide [ orderOf_dvd_iff_pow_eq_one ];
        exact fun _ => Nat.ne_of_gt ( Nat.pos_of_dvd_of_pos hd ( Fintype.card_pos ) );
      · exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun z hz₁ hz₂ => hxy <| by aesop;
    convert h_card_eq ( Nat.gcd m ( Nat.card α ) ) ( Nat.gcd_dvd_right _ _ ) using 1;
    congr! 3;
    ext a; simp +decide ;
  exact h_card_eq

/-- **Main Theorem 2** (GL(1) Langlands character count).  The number of `m`-torsion points of the
residue torus — equivalently, by self-duality of the finite cyclic character group, the number of
tame characters of order dividing `m` — is `gcd(m, p^f - 1)`. -/
theorem residue_char_count (D : PrimeDeg) (m : ℕ) :
    Nat.card {a : D.residueUnits // a ^ m = 1} = Nat.gcd m (D.p ^ D.f - 1) := by
  have : Nat.card {a : D.residueUnits // a ^ m = 1} = Nat.gcd m (Nat.card D.residueUnits) :=
    cyclic_torsion_count m
  rw [this, card_residueUnits D]

/-- The character count is an anabelomorphic invariant: equivalent residue data have the same count
of tame characters of every order. -/
theorem char_count_anabel_invariant {D D' : PrimeDeg} (h : AnabelEquiv D D') (m : ℕ) :
    Nat.card {a : D.residueUnits // a ^ m = 1} = Nat.card {a : D'.residueUnits // a ^ m = 1} := by
  rw [residue_char_count D m, residue_char_count D' m]
  obtain ⟨hp, hf⟩ := (anabelEquiv_iff D D').1 h
  rw [hp, hf]

end Anabel