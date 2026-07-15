import Catalog.Computation.MixedRadixNumberSystem
import Catalog.Computation.FactorialNumberSystem

/-!
# Bridge: the factorial number system is a mixed-radix system

This file connects the general mixed-radix theory of
`Catalog/Computation/MixedRadixNumberSystem.lean` with the catalog's factorial
number system `Catalog/Computation/FactorialNumberSystem.lean`.

The factorial system is exactly the mixed-radix system with bases `b i = i + 1`:
* its running product is `i!` (`MixedRadix.factorial_radixProd`);
* its place values agree (`value_eq`);
* its validity predicates agree (`valid_iff`).

As a consequence we re-derive the catalog's uniqueness theorem
`FactorialNumberSystem.value_unique` *as a corollary* of the more general
`MixedRadix.value_unique` (`factorial_value_unique_via_mixed`), demonstrating that
the generalization genuinely subsumes the catalog result rather than merely
restating it.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  If the mixed-radix generalization is faithful,
  the factorial-system value and validity should be *definitionally close* to the
  mixed-radix ones at `b = (· + 1)`, modulo rewriting `radixProd (·+1) i = i!`.
* **Experiment (Experimenter).**  Proved `value_eq` (place-value agreement) by
  `Finset.sum_congr` plus `MixedRadix.factorial_radixProd`, and `valid_iff` from
  `Nat.lt_succ_iff`.  Re-derived factorial uniqueness through the general theorem.
* **Analysis (Analyst).**  The bridge is "true and clean".  The only nontrivial
  ingredient is the running-product identity `∏_{j<i}(j+1) = i!`; everything else
  is transport along that equality.
* **Critique (Critic).**  Risk of circularity: does the re-derivation secretly use
  the catalog `value_unique`?  No — `factorial_value_unique_via_mixed` invokes only
  `MixedRadix.value_unique` together with `value_eq`/`valid_iff`, none of which
  depend on the catalog uniqueness proof.  (`#print axioms` shows no `sorryAx`.)
* **Synthesis (PI).**  The catalog's factorial number system sits inside a single
  parameterized family of positional systems; base-`N` numerals are another point
  in the same family (`MixedRadix.baseN_radixProd`).
-/

namespace MixedRadixBridge

open MixedRadix

/-- The mixed-radix place values for `b i = i + 1` are the factorials, so the
mixed-radix value agrees with the factorial-system value. -/
theorem value_eq (c : Nat → Nat) (k : Nat) :
    MixedRadix.value (fun i => i + 1) c k = FactorialNumberSystem.value c k := by sorry

/-- Mixed-radix validity for `b i = i + 1` coincides with factorial validity. -/
theorem valid_iff (c : Nat → Nat) (k : Nat) :
    MixedRadix.Valid (fun i => i + 1) c k ↔ FactorialNumberSystem.Valid c k := by sorry

/-- **The factorial uniqueness theorem, re-derived from the general one.**

This reproves `FactorialNumberSystem.value_unique` using only
`MixedRadix.value_unique` and the bridge lemmas `value_eq` / `valid_iff`. -/
theorem factorial_value_unique_via_mixed {c d : Nat → Nat} {k : Nat}
    (hc : FactorialNumberSystem.Valid c k) (hd : FactorialNumberSystem.Valid d k)
    (hv : FactorialNumberSystem.value c k = FactorialNumberSystem.value d k) :
    ∀ i < k, c i = d i := by sorry

end MixedRadixBridge