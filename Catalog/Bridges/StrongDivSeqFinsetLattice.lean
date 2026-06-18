import Mathlib
import Bridges.StrongDivisibilitySequences

/-! # Finitary lattice laws for strong divisibility sequences

Domain: Bridges / Conceptual unification (number theory ↔ lattice theory).

Third instalment of the strong-divisibility-sequence programme.  The binary meet law
`gcd (a m) (a n) = a (gcd m n)` (file 1) and the binary join sub-law
`lcm (a m) (a n) ∣ a (lcm m n)` (file `StrongDivSeqLatticeBridge.lean`) are here promoted
to **finite families**, exhibiting `StrongDivSeq` as a `Finset.gcd`-homomorphism and a
`Finset.lcm`-sub-homomorphism.

Main results (generic over `s : StrongDivSeq`):

* `StrongDivSeq.finset_gcd_eq` — `Finset.gcd t (a ∘ g) = a (Finset.gcd t g)`  (meet, exact).
* `StrongDivSeq.finset_lcm_dvd` — `Finset.lcm t (a ∘ g) ∣ a (Finset.lcm t g)`  (join, divides).

Cross-domain corollaries:

* `fib_finset_gcd` — `Finset.gcd t (fib ∘ g) = fib (Finset.gcd t g)`.
* `fib_finset_lcm_dvd` — `Finset.lcm t (fib ∘ g) ∣ fib (Finset.lcm t g)`.

!-- Lab Notes -- !--
Hypothesis: the binary meet/join laws should lift to arbitrary finite families by induction,
giving a finitary lattice-homomorphism picture: `a` commutes with `Finset.gcd` exactly and
with `Finset.lcm` up to divisibility.
Subtlety: `Finset.gcd`/`Finset.lcm` are stated with the `GCDMonoid` operations `gcd`/`lcm`,
which on ℕ coincide with `Nat.gcd`/`Nat.lcm` only after the normalization bridge
(`gcd_eq_nat_gcd`, `lcm` analogue).  The induction therefore interleaves `Finset.gcd_insert`
with this coercion.
Result: confirmed; both finitary laws hold, with the empty-family base cases matching the
boundary values `a 0 = 0` (gcd) and `a` of the lcm-unit `1` dividing everything (lcm).
Insight: the meet law being an *equality* while the join law is only a *divisibility* is now
visible at every arity — `StrongDivSeq` is an inf-homomorphism but only a sup-semihomomorphism
of the divisibility lattice.
!-- End Lab Notes -- !--
-/

namespace StrongDivSeq

variable (s : StrongDivSeq)

/-- **Finitary meet law.** `a` commutes with `Finset.gcd`:
`Finset.gcd t (fun i => a (g i)) = a (Finset.gcd t g)`. -/
theorem finset_gcd_eq {ι : Type*} [DecidableEq ι] (t : Finset ι) (g : ι → ℕ) :
    (t.gcd fun i => s.a (g i)) = s.a (t.gcd g) := by
  classical
  induction t using Finset.induction with
  | empty => simp [s.map_zero]
  | insert a t ha ih =>
    rw [Finset.gcd_insert, Finset.gcd_insert, ih, gcd_eq_nat_gcd, gcd_eq_nat_gcd, s.gcd_eq]

/-- **Finitary join sub-law.** `a` carries `Finset.lcm` up to divisibility:
`Finset.lcm t (fun i => a (g i)) ∣ a (Finset.lcm t g)`. -/
theorem finset_lcm_dvd {ι : Type*} [DecidableEq ι] (t : Finset ι) (g : ι → ℕ) :
    (t.lcm fun i => s.a (g i)) ∣ s.a (t.lcm g) := by
  classical
  induction t using Finset.induction with
  | empty => simp
  | insert a t ha ih =>
    rw [Finset.lcm_insert]
    refine lcm_dvd ?_ ?_
    · exact s.dvd_of_dvd (by rw [Finset.lcm_insert]; exact dvd_lcm_left _ _)
    · exact ih.trans (s.dvd_of_dvd (by rw [Finset.lcm_insert]; exact dvd_lcm_right _ _))

end StrongDivSeq

/-! ## Fibonacci corollaries -/

/-- **Fibonacci finitary meet law**: `Finset.gcd t (fib ∘ g) = fib (Finset.gcd t g)`. -/
theorem fib_finset_gcd {ι : Type*} [DecidableEq ι] (t : Finset ι) (g : ι → ℕ) :
    (t.gcd fun i => Nat.fib (g i)) = Nat.fib (t.gcd g) :=
  fibSDS.finset_gcd_eq t g

/-- **Fibonacci finitary join sub-law**: `Finset.lcm t (fib ∘ g) ∣ fib (Finset.lcm t g)`. -/
theorem fib_finset_lcm_dvd {ι : Type*} [DecidableEq ι] (t : Finset ι) (g : ι → ℕ) :
    (t.lcm fun i => Nat.fib (g i)) ∣ Nat.fib (t.lcm g) :=
  fibSDS.finset_lcm_dvd t g