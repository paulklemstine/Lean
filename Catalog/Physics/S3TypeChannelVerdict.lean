import Physics.S3TypeChannelAlgebra
import Physics.S3TypeChannelGeneralized

/-!
# THREE-FIELDS-ONE-ANSWER: the assembled verdict

One statement gathering the arithmetic and the information-theoretic halves of the
development.  For every prime `p ∉ {2,3}`:

* the resolvent character of `x³ - 3` (`disc = -243`) and of `x³ - 2` (`disc = -108`) at
  `p` is literally `p mod 3` — the two discriminants differ, their squarefree kernel `-3`
  does not;
* the residue → splitting-type channel of all three `S₃` cubics (`-243`, `-108` and `-23`,
  the last over the residue group `(ℤ/23)ˣ` with `11` classes per character fibre) has
  mutual information exactly `1` bit, and so does each semiprime pair channel;
* the value `1` is sharp: the root-count readout of the same field, and both channels of a
  *cyclic* cubic, all differ from `1`.

Every conjunct is proved; nothing here is a definition unfolding.
-/

namespace S3Verdict

open S3Channel S3Universal S3Lossy S3General

/-- **THREE FIELDS, ONE ANSWER.**  The full verdict: two independent arithmetic
identifications of the coupling bit, four exact one-bit channel values across three
`S₃` cubics and two residue groups, and three strict separations showing that `1` is not
an artefact. -/
theorem three_fields_one_answer_full (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    (IsSquare ((-243 : ℤ) : ZMod p) ↔ p % 3 = 1) ∧
      (IsSquare ((-108 : ℤ) : ZMod p) ↔ p % 3 = 1) ∧
      Imut (residueTable chi3) = 1 ∧ Imut (residueTable chi23) = 1 ∧
      Imut (pairTable chi3) = 1 ∧ Imut (pairTable chi23) = 1 ∧
      Imut rootTable < 1 ∧ Imut c3TypeTable < 1 ∧ 1 < Imut c3FrobTable := by
  refine ⟨S3Algebra.isSquare_neg243_iff p hp2 hp3, S3Algebra.isSquare_neg108_iff p hp2 hp3,
    Ires_xcubed_sub_three, Ires_xcubed_sub_x_sub_one, Ipair_mod_three, Ipair_mod_twentythree,
    Imut_rootTable_lt_one, ?_, ?_⟩
  · exact (galois_group_is_detected).2.1
  · exact (galois_group_is_detected).2.2

end S3Verdict