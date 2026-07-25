/-
# Stochastic Galois Theory: the Random-Permutation Side of the Dictionary

Over a finite field `K` with `q = |K|`, a uniformly random monic polynomial of degree
`n` behaves, in its factorization statistics, like the cycle type of a uniformly random
permutation in the symmetric group `S_n`.  Two exact identities anchor this dictionary:

* on the *arithmetic* side, `StochasticGalois.total_root_incidences` shows that, summed
  over all `q^n` monic degree-`n` polynomials, the total number of roots is exactly
  `q^n`; equivalently the **expected number of roots is `1`**;
* on the *combinatorial* side, the present file proves the mirror identity: summed over
  all `n!` permutations of `n` letters, the total number of fixed points is exactly `n!`;
  equivalently the **expected number of fixed points is `1`**.

Because a root of a monic polynomial is exactly a linear factor, and a linear factor is
exactly a fixed point of the Frobenius permutation on the roots, the two identities are
the same statement seen from opposite sides of the correspondence.

Beyond fixed points we quantify the *transitive* end of the dictionary.  A monic
polynomial of degree `n` is irreducible precisely when the Frobenius permutation acts as
a single `n`-cycle on its roots; on the permutation side the proportion of `n`-cycles in
`S_n` is exactly `1 / n`.  We prove the exact count `#{n\text{-cycles}} = (n-1)!` and the
probability identity `#{n\text{-cycles}} \cdot n = n!`.  This is the general-`n`
generalization of the degree-`2` computation in `StochasticGaloisDegreeTwo.lean`, where
the proportion of irreducible quadratics tends to `1/2`, the fraction of transpositions
in `S_2`.

The `bridge_fixedPoints_roots` theorem then couples the two exact identities into a
single cross-domain equation, tying the arithmetic file to the combinatorial one.

-- !-- Lab Notes -- !--
--
-- Hypothesis (Hypothesizer): the "random polynomial ≈ random permutation" heuristic
--   should hold as an *exact* finite identity at the level of first moments, not merely
--   asymptotically. Precisely: expected #roots over F_q equals expected #fixed points
--   over S_n, both equal to 1, for every q and every n ≥ 1.
--
-- Experiment (Experimenter): we proved the permutation-side identity
--   ∑_{σ∈S_n} #fix(σ) = n!  by double counting (Fubini on the incidence indicator)
--   together with the orbit–stabilizer count |{σ : σ i = i}| = (n-1)!.  We also proved
--   #{n-cycles in S_n} = (n-1)! from Mathlib's cycle-type enumeration, and derived the
--   probability identity #{n-cycles}·n = n!.
--
-- Analysis (Analyst): the first-moment identity is genuinely *exact and dimension-free*,
--   surviving for all q and n; the n-cycle proportion 1/n is the exact combinatorial
--   value that the (heuristic) proportion of irreducibles approaches.  The degree-2
--   file is recovered as the n = 2 slice: (2-1)! = 1 transposition, proportion 1/2.
--
-- Critique (Critic): the naive "Galois group is S_n" statement is FALSE over finite
--   fields (Galois groups there are cyclic); see `StochasticGaloisCyclic.lean`.  What is
--   true, and what we formalize, is the *cycle-type statistics* correspondence.  The
--   n = 0 boundary is excluded: S_0 has one element with zero fixed points, so the sum is
--   0 ≠ 0! = 1; this is why the fixed-point identity requires n ≥ 1, exactly mirroring
--   the `0 < n` hypothesis of `total_root_incidences`.
--
-- Synthesis (PI): the arithmetic and combinatorial first-moment identities are unified by
--   `bridge_fixedPoints_roots`, an exact cross-domain equation valid for every finite
--   commutative ring K and every n ≥ 1.
-/
import Mathlib
import Novelty.StochasticGaloisRoots

open Finset Equiv
open scoped BigOperators

namespace StochasticGalois

/-! ## The transitive end: `n`-cycle statistics in `S_n` -/

/-- **Exact count of `n`-cycles.** The number of permutations of `n` letters that consist
of a single `n`-cycle is `(n-1)!`.  These are exactly the permutations arising as the
Frobenius action on the roots of an *irreducible* monic polynomial of degree `n`. -/
theorem card_nCycles (n : ℕ) (hn : 2 ≤ n) :
    #({g | g.cycleType = {n}} : Finset (Perm (Fin n))) = (n - 1).factorial := by
  have h := Equiv.Perm.card_of_cycleType_singleton (α := Fin n) (n := n) hn (by simp)
  rwa [Fintype.card_fin, Nat.choose_self, mul_one] at h

/-- **The `1/n` law for irreducibility.** The number of `n`-cycles in `S_n`, multiplied
by `n`, equals `n!`; equivalently a uniformly random permutation of `n` letters is an
`n`-cycle with probability exactly `1/n`.  This is the exact combinatorial value that the
proportion of irreducible monic degree-`n` polynomials over `F_q` approaches. -/
theorem nCycles_mul_eq_factorial (n : ℕ) (hn : 2 ≤ n) :
    #({g | g.cycleType = {n}} : Finset (Perm (Fin n))) * n = n.factorial := by
  rw [card_nCycles n hn, mul_comm, Nat.mul_factorial_pred (by omega)]

/-! ## The fixed-point end: first moment of the number of fixed points -/

/-- **Orbit–stabilizer fiber count.** For a fixed letter `i`, exactly `(n-1)!` permutations
of `n` letters fix `i`. -/
theorem card_perms_fixing (n : ℕ) (hn : 0 < n) (i : Fin n) :
    #(univ.filter (fun σ : Perm (Fin n) => σ i = i)) = (n - 1).factorial := by
  haveI : NeZero n := ⟨hn.ne'⟩
  have hstab : #(univ.filter (fun σ : Perm (Fin n) => σ i = i))
      = Fintype.card (MulAction.stabilizer (Perm (Fin n)) i) := by
    rw [Fintype.card_subtype]
    rfl
  have horbit : Fintype.card (MulAction.orbit (Perm (Fin n)) i) = n := by
    rw [MulAction.orbit_eq_univ]; simp
  have hos := MulAction.card_orbit_mul_card_stabilizer_eq_card_group (Perm (Fin n)) i
  rw [horbit, Fintype.card_perm, Fintype.card_fin] at hos
  have hmul : n * (n - 1).factorial = n.factorial := Nat.mul_factorial_pred hn.ne'
  rw [hstab]
  exact Nat.eq_of_mul_eq_mul_left hn (hos.trans hmul.symm)

/-- **First moment of fixed points.** Summed over all `n!` permutations of `n` letters,
the total number of fixed points is exactly `n!`; equivalently the expected number of
fixed points of a uniformly random permutation is `1`.  This is the permutation-side
mirror of `total_root_incidences`. -/
theorem total_fixedPoints (n : ℕ) (hn : 0 < n) :
    ∑ σ : Perm (Fin n), #(univ.filter (fun i : Fin n => σ i = i)) = n.factorial := by
  simp_rw [card_filter]
  rw [Finset.sum_comm]
  have hcong : ∀ i : Fin n,
      ∑ σ : Perm (Fin n), (if σ i = i then 1 else 0) = (n - 1).factorial := by
    intro i; rw [← card_filter]; exact card_perms_fixing n hn i
  rw [Finset.sum_congr rfl (fun i _ => hcong i), Finset.sum_const, card_univ,
    Fintype.card_fin, smul_eq_mul]
  exact Nat.mul_factorial_pred hn.ne'

/-! ## The cross-domain bridge -/

variable {K : Type*} [CommRing K] [Fintype K] [DecidableEq K]

/-- **First-moment bridge.** For every finite commutative ring `K` and every `n ≥ 1`, the
total number of `(polynomial, root)` incidences over the `q^n` monic degree-`n`
polynomials, scaled by `n!`, equals the total number of `(permutation, fixed point)`
incidences over the `n!` permutations of `n` letters, scaled by `q^n`.  Both sides equal
`q^n · n!`, so the *expected number of roots* over `F_q` equals the *expected number of
fixed points* over `S_n`: both are `1`. -/
theorem bridge_fixedPoints_roots (n : ℕ) (hn : 0 < n) :
    (∑ v : Fin n → K, #(univ.filter (fun r : K => monicEval n v r = 0))) * n.factorial
      = (∑ σ : Perm (Fin n), #(univ.filter (fun i : Fin n => σ i = i)))
          * (Fintype.card K) ^ n := by
  rw [total_root_incidences n hn, total_fixedPoints n hn, mul_comm]

/-! ## Examples, generalizations, and boundaries (PEGB) -/

-- Example: `S_3` contains exactly `(3-1)! = 2` three-cycles, and `2 * 3 = 6 = 3!`.
example : #({g | g.cycleType = {3}} : Finset (Perm (Fin 3))) = 2 := by
  simpa using card_nCycles 3 (by norm_num)

#check @card_nCycles
#check @total_fixedPoints
#check @bridge_fixedPoints_roots

-- Boundary: the identity fails at `n = 0`. `S_0` has a single element (the empty
-- permutation) with no fixed points, so the total is `0`, whereas `0! = 1`.  This is why
-- `total_fixedPoints` and `total_root_incidences` both require `0 < n`.
example : (∑ σ : Perm (Fin 0), #(univ.filter (fun i : Fin 0 => σ i = i))) = 0 := by
  simp

-- Generalization: the bridge holds over *any* finite commutative ring, not merely fields,
-- because the root-incidence count `total_root_incidences` is proved at that generality.
example (p : ℕ) [Fact p.Prime] (n : ℕ) (hn : 0 < n) :
    (∑ v : Fin n → ZMod p, #(univ.filter (fun r : ZMod p => monicEval n v r = 0)))
        * n.factorial
      = (∑ σ : Perm (Fin n), #(univ.filter (fun i : Fin n => σ i = i))) * p ^ n := by
  have h := bridge_fixedPoints_roots (K := ZMod p) n hn
  rwa [ZMod.card p] at h

end StochasticGalois