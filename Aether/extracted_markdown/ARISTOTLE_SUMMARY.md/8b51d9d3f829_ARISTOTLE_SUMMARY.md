# Summary of changes for run 14b63eb5-441c-4e4c-9921-9eb0f361b4c6
Created `Catalog/Algebra/BerggrenLorentz/TropicalCertificate.lean`, a complete, fully verified theorem package (no `sorry`s; only standard axioms `propext`, `Classical.choice`, `Quot.sound`) built on top of the existing `Algebra.BerggrenLorentz.Core` API. It compiles via `lake build Algebra.BerggrenLorentz.TropicalCertificate`.

Index convention (documented in the module header, fixed by the core file): generator index `0` ↦ `childA`, `1` ↦ `childB` (the `B` generator, the improper `det = -1` one), `2` ↦ `childC`.

Contents:
- Word statistic `bCount : List (Fin 3) → ℕ` counting occurrences of the `B` index `1`, with `bCount_nil`, `bCount_cons`, `bCount_append`.
- Triple action: `hyp` (hypotenuse = third coordinate), `applyLetter` bundling the core `childA/childB/childC` maps, and `applyWord` folding letters along a word, with `applyWord_nil`/`applyWord_cons`.
- `Admissible` (strictly positive Pythagorean triple) and its preservation: `applyLetter_admissible` and `applyWord_admissible` — the latter is the intended `applyWord_preserves` statement, proved by induction using the core `child*_preserves_pythag` and `pythag_hyp_ge_leg_*` lemmas.
- Generator-level hypotenuse inequalities derived from the core explicit formulas: `childA_hyp_nondecr`, `childC_hyp_nondecr` (nondecreasing), and `childB_hyp_growth` (`3 * hyp t ≤ hyp (childB t)`), unified as `letter_hyp_growth`.
- Main growth theorem `hyp_growth`: for every admissible triple `t`, `3 ^ (bCount w) * hyp t ≤ hyp (applyWord w t)`, proved by structural induction on the word, splitting on the head letter.
- Functorial packaging: `tropCert w = Multiplicative.ofAdd (bCount w) : Multiplicative ℕ` with `tropCert_nil`, `tropCert_append` (concatenation ↦ multiplication, i.e. a monoid homomorphism), the decoding theorem `tropCert_untrop` recovering `bCount w` as the underlying exponent, and `tropCert_hyp_lower_bound` restating the growth bound through the decoded exponent. The module comment explains the deliberate choice of `Multiplicative ℕ` over an exotic tropical semiring for a clean, friction-free functorial certificate.

This realizes the objective: the number of `B` letters in a Berggren word functorially certifies the lower bound `3 ^ bCount` on hypotenuse growth.

Note: the active Lean project root with the prebuilt Mathlib cache is the `Catalog/` subproject; its package cache was linked to the already-built dependencies so the new module compiles against the existing Mathlib build.