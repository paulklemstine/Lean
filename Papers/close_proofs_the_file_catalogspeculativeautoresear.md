# Skip Evidence Justification

The task was to close three `sorry` placeholders in an existing, fully specified
Lean development. The statements are not open conjectures requiring exploratory
computational evidence; they are *transport/equivalence* lemmas whose truth is
already pinned down by the surrounding definitions:

* `value_eq` and `valid_iff` are definitional bridges between two positional
  number-system formalizations, each reducing to an already-proved identity in
  the imported file (`MixedRadix.factorial_radixProd`,
  `MixedRadix.factorial_valid_iff`).
* `factorial_value_unique_via_mixed` is a re-derivation of an established theorem
  (`FactorialNumberSystem.value_unique`) through the general
  `MixedRadix.value_unique`.

The correctness of these claims is settled by the Lean kernel itself: the file
builds with no `sorry` and the final theorem's axiom set is clean. A separate
numerical counterexample hunt would add nothing beyond what the machine-checked
proof already guarantees, so the computational-evidence stage is skipped.
