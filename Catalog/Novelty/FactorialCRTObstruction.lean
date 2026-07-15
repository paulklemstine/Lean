import Mathlib

/-!
# A sharp low-stage obstruction to factorial CRT coordinates

Factorial digits have radices `1, 2, ..., k`, whose product is `k!`.  It is
therefore tempting to strengthen the mixed-radix bijection to an additive or
ring equivalence

`ZMod (k!) ≃ ZMod 2 × ... × ZMod k`.

This file proves that the strengthening works at `k = 3`, by the Chinese
remainder theorem, but already fails at `k = 4`.  The failure is stronger than
nonmultiplicativity: there is no additive equivalence.  Every element of
`ZMod 2 × ZMod 3 × ZMod 4` is killed by `12`, whereas `12` does not kill `1`
in `ZMod 24`.
-/

namespace FactorialCRTObstruction

/-- The nontrivial residue factors associated with factorial radices through
stage three.  (The omitted `ZMod 1` factor is a singleton.) -/
abbrev FactorialResidues3 := ZMod 2 × ZMod 3

/-- The nontrivial residue factors associated with factorial radices through
stage four. -/
abbrev FactorialResidues4 := ZMod 2 × ZMod 3 × ZMod 4

/-- At stage three, factorial residue coordinates really are CRT coordinates:
`3! = 2 * 3`, and the two nontrivial radices are coprime. -/
noncomputable def factorialThreeCRT :
    ZMod (Nat.factorial 3) ≃+* FactorialResidues3 :=
  (ZMod.ringEquivCongr (by decide)).trans
    (ZMod.chineseRemainder (by decide : Nat.Coprime 2 3))

/-- The stage-three CRT map is the expected simultaneous reduction on natural
numbers.  This records its compatibility with the canonical integer input. -/
theorem factorialThreeCRT_natCast (n : Nat) :
    factorialThreeCRT (n : ZMod (Nat.factorial 3)) =
      ((n : ZMod 2), (n : ZMod 3)) := by
  ext <;> simp [factorialThreeCRT, ZMod.chineseRemainder]

/-- Twelve annihilates every putative stage-four residue coordinate.  The
proof exposes the non-coprime overlap: each modulus `2`, `3`, and `4` divides
`12`. -/
theorem twelve_smul_factorialResidues4 (x : FactorialResidues4) :
    12 • x = 0 := by
  rcases x with ⟨x2, x3, x4⟩
  ext <;> fin_cases x2 <;> fin_cases x3 <;> fin_cases x4 <;> decide

/-- **Counterexample to additive factorial CRT coordinates.**

Although both sides have 24 elements, the additive groups are not isomorphic.
Thus the ordinary factorial-code bijection at length four cannot be made into
an additive equivalence with the direct product of its radix residue rings. -/
theorem no_factorial_four_add_equiv :
    ¬ Nonempty (ZMod (Nat.factorial 4) ≃+ FactorialResidues4) := by
  rintro ⟨e⟩
  have hz : 12 • e (1 : ZMod (Nat.factorial 4)) = 0 :=
    twelve_smul_factorialResidues4 _
  have himage : e (12 • (1 : ZMod (Nat.factorial 4))) = e 0 := by
    rw [map_nsmul, hz, map_zero]
  have hsource : 12 • (1 : ZMod (Nat.factorial 4)) = 0 := e.injective himage
  have hnonzero : 12 • (1 : ZMod (Nat.factorial 4)) ≠ 0 := by decide
  exact hnonzero hsource

/-- A fortiori, there is no ring equivalence at stage four.  This formally
refutes the naive claim that cardinality alone upgrades factorial mixed-radix
coordinates to Chinese-remainder coordinates. -/
theorem no_factorial_four_ring_equiv :
    ¬ Nonempty (ZMod (Nat.factorial 4) ≃+* FactorialResidues4) := by
  rintro ⟨e⟩
  exact no_factorial_four_add_equiv ⟨e.toAddEquiv⟩

end FactorialCRTObstruction