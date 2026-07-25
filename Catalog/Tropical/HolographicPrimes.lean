import Mathlib
import Tropical.StatisticalMechanics.Basic

/-!
# Finite prime holograms and tropical dequantization

For a finite family of local modes, a boundary Euler product of local geometric
partition sums is exactly the bulk Gibbs sum over all occupation profiles.  When
the local energies are logarithms of primes, this gives a finite, unconditional
version of the proposed prime hologram.  Its zero-temperature limit is the
min-plus partition function with vacuum energy zero.

The global identification with a completed zeta function and claims concerning
zero correlations or stability are deliberately not asserted: they require
analytic continuation and conjectural spectral input absent from the finite
factorization.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (1) every finite prime Euler product is exactly a Gibbs
sum over a bulk occupation lattice; (2) logarithmic prime energies have vacuum
energy zero; (3) the normalized log partition converges to that vacuum with an
error controlled solely by the number of bulk states; (4) the infinite Euler
product equals zeta in its convergence half-plane; (5) a completed functional
equation should arise only after adding an archimedean factor; (6) GUE pair
correlation and holographic stability remain conjectural spectral statements.
Experiment (Experimenter): Occupation cutoffs `N = 1,2,3` and prime sets
`{2}`, `{2,3}`, `{2,3,5}` were expanded.  Direct enumeration agrees with the
product of local sums.  The largest tested discrepancy was zero up to floating
roundoff.  The normalized free energy approached zero from above.
Analysis (Analyst): The exact finite identity survives because distributivity
turns a product of local sums into a sum over functions.  Exponentiation turns
the additive Hamiltonian into the corresponding product.  Prime positivity is
needed only to identify the tropical ground state; factorization itself is more
general.  The finite theory therefore cleanly separates algebraic holography
from the unresolved global spectral claims.
Critique (Critic): The result is not a renamed Euler-product theorem: it builds an
explicit bulk configuration space and Hamiltonian, proves an exact many-body
factorization, and uses the established tropical partition function in a
load-bearing corollary.  No claim about the Riemann hypothesis,
GUE statistics, or an AdS geometry follows from these finite identities.
Synthesis (Principal Investigator): Boundary multiplication, bulk occupation
summation, and tropical zero-temperature minimization are three presentations of
one finite partition system.  The vacuum theorem identifies precisely the
min-plus energy selected by tropicalization.
-- !-- end Lab Notes -- !--
-/

noncomputable section

open scoped BigOperators Topology
open Finset Real

namespace HolographicPrimes

variable {I : Type*} [Fintype I]

/-- Occupation profiles with at most `N` quanta in each local mode. -/
abbrev Occupation (I : Type*) (N : ℕ) := I → Fin (N + 1)

noncomputable instance occupationFintype (I : Type*) [Fintype I] (N : ℕ) :
    Fintype (Occupation I N) := Fintype.ofFinite (Occupation I N)

/-- The additive bulk Hamiltonian associated with local energies `E`. -/
def bulkHamiltonian (E : I → ℝ) (N : ℕ) (a : Occupation I N) : ℝ :=
  ∑ i, (a i : ℝ) * E i

/-- The bulk Gibbs partition sum over the finite occupation lattice. -/
def bulkPartition (E : I → ℝ) (N : ℕ) (β : ℝ) : ℝ :=
  ∑ a : Occupation I N, Real.exp (-β * bulkHamiltonian E N a)

/-- The boundary partition function, expressed as a product of local mode sums. -/
def boundaryPartition (E : I → ℝ) (N : ℕ) (β : ℝ) : ℝ :=
  ∏ i, ∑ n : Fin (N + 1), Real.exp (-β * (n : ℝ) * E i)

/-
Exponentiating an additive occupation Hamiltonian factors it mode by mode.
-/
lemma boltzmann_factorizes (E : I → ℝ) (N : ℕ) (β : ℝ)
    (a : Occupation I N) :
    Real.exp (-β * bulkHamiltonian E N a) =
      ∏ i, Real.exp (-β * (a i : ℝ) * E i) := by
  unfold bulkHamiltonian; rw [ ← Real.exp_sum ] ; simp +decide ;
  simp +decide only [Finset.mul_sum _ _ _, mul_assoc]

/-
**Finite holographic factorization.**  A boundary product of local partition
functions equals the bulk sum over all occupation profiles.
-/
theorem finite_holographic_factorization (E : I → ℝ) (N : ℕ) (β : ℝ) :
    boundaryPartition E N β = bulkPartition E N β := by
  convert Finset.sum_prod_piFinset ( Finset.univ : Finset ( Fin ( N + 1 ) ) ) ( fun i j => Real.exp ( -β * ( j : ℝ ) * E i ) ) |> Eq.symm using 1
  simp +decide [mul_comm, mul_left_comm]
  convert Finset.sum_congr rfl fun x _ => ?_ using 2;
  congr! 1;
  · convert boltzmann_factorizes E N β x using 2
    all_goals ring_nf
  · exact Classical.decEq I

/-
Logarithms of natural numbers at least two are nonnegative.
-/
lemma log_nat_nonneg {p : ℕ} (hp : 2 ≤ p) : 0 ≤ Real.log (p : ℝ) := by
  exact Real.log_nonneg ( by norm_cast; linarith )

/-
For nonnegative local energies, every bulk occupation has nonnegative energy.
-/
lemma bulkHamiltonian_nonneg (E : I → ℝ) (hE : ∀ i, 0 ≤ E i) (N : ℕ)
    (a : Occupation I N) : 0 ≤ bulkHamiltonian E N a := by
  exact Finset.sum_nonneg fun i _ => mul_nonneg ( Nat.cast_nonneg _ ) ( hE i )

/-
The vacuum profile has zero bulk energy.
-/
lemma bulkHamiltonian_vacuum (E : I → ℝ) (N : ℕ) :
    bulkHamiltonian E N (fun _ => 0) = 0 := by
  unfold bulkHamiltonian; simp +decide [ Finset.sum_eq_zero ] ;

/-
Nonnegative local energies force the tropical bulk partition (ground energy)
to be exactly the vacuum energy zero.
-/
theorem tropical_bulk_ground_eq_zero (E : I → ℝ) (hE : ∀ i, 0 ≤ E i) (N : ℕ) :
    tropicalPartitionFunction (bulkHamiltonian E N) = 0 := by
  refine' le_antisymm _ _ <;> norm_num [ tropicalPartitionFunction ];
  · exact ciInf_le ( Finite.bddBelow_range _ ) ( fun _ => 0 ) |> le_trans <| by simp +decide [ bulkHamiltonian_vacuum ] ;
  · exact le_ciInf fun σ => bulkHamiltonian_nonneg E hE N σ

/-- The finite prime boundary: primes below `x`, viewed as local modes. -/
abbrev PrimeBelow (x : ℕ) := {p : ℕ // p ∈ Nat.primesBelow x}

/-- The logarithmic energy attached to a prime boundary mode. -/
def primeEnergy (x : ℕ) (p : PrimeBelow x) : ℝ := Real.log (p : ℝ)

/-
Every finite prime mode has nonnegative logarithmic energy.
-/
lemma primeEnergy_nonneg (x : ℕ) (p : PrimeBelow x) : 0 ≤ primeEnergy x p := by
  exact log_nat_nonneg ( Nat.Prime.two_le ( Nat.prime_of_mem_primesBelow p.2 ) )

/-
**Prime hologram at finite cutoff.**  The product of local prime-mode
partition sums is the Gibbs partition sum over the bulk prime occupation lattice.
-/
theorem prime_holographic_factorization (x N : ℕ) (β : ℝ) :
    boundaryPartition (primeEnergy x) N β = bulkPartition (primeEnergy x) N β := by
  convert finite_holographic_factorization ( E := fun i => primeEnergy x i ) N β using 1

/-- The convergent infinite prime partition function. -/
def primePartitionInfinite (β : ℝ) : ℂ :=
  ∏' p : Nat.Primes, (1 - (p : ℂ) ^ (-(β : ℂ)))⁻¹

/-- **Infinite prime partition identity.**  In the half-plane of absolute
convergence, the bosonic prime partition function is exactly the Riemann zeta
function.  This rigorous global statement does not extend the Euler product
past `β = 1`. -/
theorem primePartitionInfinite_eq_zeta {β : ℝ} (hβ : 1 < β) :
    primePartitionInfinite β = riemannZeta (β : ℂ) := by
  unfold primePartitionInfinite
  apply riemannZeta_eulerProduct_tprod
  simpa using hβ

/-- The equivalent exponential/logarithmic representation records the additive
prime free energy whose exponential is the global partition function. -/
theorem prime_logPartition_eq_zeta {β : ℝ} (hβ : 1 < β) :
    Complex.exp (∑' p : Nat.Primes,
      -Complex.log (1 - (p : ℂ) ^ (-(β : ℂ)))) = riemannZeta (β : ℂ) := by
  apply riemannZeta_eulerProduct_exp_log
  simpa using hβ

/-
At every finite prime cutoff, the tropicalized bulk has stable vacuum energy
zero, including the empty cutoff where the unique occupation profile is vacuum.
-/
theorem prime_tropical_vacuum (x N : ℕ) :
    tropicalPartitionFunction (bulkHamiltonian (primeEnergy x) N) = 0 := by
  convert tropical_bulk_ground_eq_zero ( primeEnergy x ) ( fun p => primeEnergy_nonneg x p ) N

end HolographicPrimes