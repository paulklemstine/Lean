/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Prime-Spectral Schrödinger Bridge for Closure-Generated Proof Semirings

This file establishes a bridge between proof-theoretic derivability in coherent
closure proof semirings and the zero-noise limit of Schrödinger bridge costs
on the prime spectrum.

## Main Definitions

* `CoherentClosureProofSemiring` — a bounded distributive lattice with a closure
  operator and prime separation axiom
* `PrimeSpectrum` — spectral points: bounded lattice homomorphisms to Bool
  compatible with the closure operator
* `derivable` — the syntactic preorder: `derivable x y ↔ cl x ≤ cl y`
* `freeEnergyGap` — the optimal spectral transport cost measuring the obstruction
  to derivability
* `schrodingerCost` — the ε-regularized Schrödinger bridge cost on the spectrum

## Main Results

* `derivable_iff_forall_primeSpectrum` — derivability equals universal prime
  spectrum validation (adequacy theorem)
* `derivable_iff_freeEnergyGap_zero` — derivability equals vanishing free energy gap
* `schrodingerCost_tendsto_freeEnergyGap` — the Schrödinger cost converges to the
  free energy gap as ε → 0⁺
* `derivable_iff_tendsto_schrodingerCost_zero` — the main theorem: derivability
  equals the Schrödinger cost converging to zero
-/

import Mathlib

open scoped ENNReal NNReal

namespace PrimeSpectralBridge

/-! ## Core Algebraic Structures -/

/-- A coherent closure proof semiring is a bounded distributive lattice equipped with
a closure operator satisfying extensiveness, idempotency, monotonicity, and the
prime separation property.

The prime separation axiom encapsulates the Stone representation theorem for the
quotient lattice of closed elements: if `cl x ≤ cl y` fails, there exists a
bounded lattice homomorphism to Bool (a "spectral point") that witnesses the failure
while respecting the closure structure.

This axiom follows from the prime ideal theorem for distributive lattices
(`DistribLattice.prime_ideal_of_disjoint_filter_ideal`) applied to the sublattice
of closed elements `{a | cl a = a}`. -/
class CoherentClosureProofSemiring (S : Type*) extends DistribLattice S, BoundedOrder S where
  /-- The closure operator -/
  cl : S → S
  /-- Extensiveness: every element is below its closure -/
  cl_extensive : ∀ x, x ≤ cl x
  /-- Idempotency: applying closure twice equals applying it once -/
  cl_idempotent : ∀ x, cl (cl x) = cl x
  /-- Monotonicity: closure preserves the lattice ordering -/
  cl_monotone : ∀ x y, x ≤ y → cl x ≤ cl y
  /-- Prime separation: non-derivability is witnessed by a spectral point.
  If `cl x ≤ cl y` fails, there exists a bounded lattice homomorphism `h : S → Bool`
  that commutes with closure and sends `x` to `true` and `y` to `false`. -/
  prime_separation : ∀ x y, ¬(cl x ≤ cl y) →
    ∃ (h : BoundedLatticeHom S Bool), (∀ z, h (cl z) = h z) ∧ h x = true ∧ h y = false

variable {S : Type*} [CoherentClosureProofSemiring S]

/-- The closure operator of a coherent closure proof semiring. -/
abbrev cl' (x : S) : S := CoherentClosureProofSemiring.cl x

/-- Derivability: `x` derives `y` when `cl x ≤ cl y`, i.e., the closure of the
premise entails the closure of the conclusion. This defines a preorder on `S`. -/
def derivable (x y : S) : Prop := cl' x ≤ cl' y

/-- A prime spectral point is a bounded lattice homomorphism to Bool that commutes
with the closure operator. Each spectral point represents a "model" or "valuation"
of the proof semiring, and derivability is characterized by agreement of all
spectral points (the adequacy theorem). -/
structure PrimeSpectrum (S : Type*) [CoherentClosureProofSemiring S] where
  /-- The underlying lattice homomorphism -/
  hom : BoundedLatticeHom S Bool
  /-- Compatibility with the closure operator -/
  cl_compat : ∀ x, hom (cl' x) = hom x

instance : FunLike (PrimeSpectrum S) S Bool where
  coe p := p.hom
  coe_injective' := by
    intro p q h
    cases p; cases q
    simp only [PrimeSpectrum.mk.injEq]
    exact BoundedLatticeHom.ext (congr_fun h)

@[ext]
theorem PrimeSpectrum.ext' {p q : PrimeSpectrum S} (h : ∀ x, p x = q x) : p = q :=
  DFunLike.ext p q h

/-! ## Basic Properties of Derivability -/

theorem derivable_refl (x : S) : derivable x x := le_refl _

theorem derivable_trans {x y z : S} (hxy : derivable x y) (hyz : derivable y z) :
    derivable x z := le_trans hxy hyz

theorem derivable_of_le {x y : S} (h : x ≤ y) : derivable x y :=
  CoherentClosureProofSemiring.cl_monotone x y h

/-! ## The Adequacy Theorem -/

/-
Soundness: if `x` derives `y`, then every spectral point that validates `x`
also validates `y`.
-/
theorem forall_primeSpectrum_of_derivable {x y : S} (h : derivable x y) :
    ∀ p : PrimeSpectrum S, p x = true → p y = true := by
  intro p hp;
  obtain ⟨q, hq⟩ := p;
  rename_i h';
  cases h';
  have h_monotone : ∀ x y : S, x ≤ y → q x ≤ q y := by
    exact fun x y hxy => by simpa using congr_arg ( fun z => q z ) ( inf_eq_left.mpr hxy ) ;
  exact h_monotone _ _ h |> fun h => by aesop;

/-
Completeness: if every spectral point that validates `x` also validates `y`,
then `x` derives `y`. Uses the prime separation axiom.
-/
theorem derivable_of_forall_primeSpectrum {x y : S}
    (h : ∀ p : PrimeSpectrum S, p x = true → p y = true) :
    derivable x y := by
  rename_i h';
  cases' h' with h₁ h₂ h₃ h₄ h₅;
  rename_i h₆ h₇;
  contrapose! h;
  obtain ⟨ h, hh₁, hh₂, hh₃ ⟩ := h₇ x y h;
  refine' ⟨ _, _, _ ⟩;
  use h;
  grind +qlia;
  · exact hh₂;
  · exact hh₃.symm ▸ by decide;

/-- **Adequacy Theorem**: Derivability in a coherent closure proof semiring is
equivalent to universal validation by all prime spectral points. This is the
Stone-type representation theorem that connects syntax (derivability) with
semantics (spectral points). -/
theorem derivable_iff_forall_primeSpectrum {x y : S} :
    derivable x y ↔ ∀ p : PrimeSpectrum S, p x = true → p y = true :=
  ⟨forall_primeSpectrum_of_derivable, derivable_of_forall_primeSpectrum⟩

/-! ## Spectral Transport Definitions -/

variable [Fintype (PrimeSpectrum S)] [DecidableEq (PrimeSpectrum S)]

/-- The spectral indicator: assigns weight 1 to primes that validate `x`,
and 0 to primes that don't. This is the "source marginal" for transport. -/
noncomputable def spectralIndicator (x : S) (p : PrimeSpectrum S) : ℝ≥0∞ :=
  if p x = true then 1 else 0

/-- A Markov cost kernel on the spectrum: zero self-transition cost and strictly
positive cross-transition cost. This ensures that non-trivial transport always
incurs a positive energetic penalty. -/
structure IsMarkovKernel (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞) : Prop where
  /-- Self-transitions are free -/
  diag_zero : ∀ p, K p p = 0
  /-- Cross-transitions have positive cost -/
  off_diag_pos : ∀ p q, p ≠ q → 0 < K p q

/-- The **free energy gap** measures the spectral obstruction to derivability.
For each prime `p` that validates `x`, the gap computes:
- 0 if `p` also validates `y` (no obstruction at this prime)
- the minimum transport cost to reach any `y`-validating prime otherwise

The free energy gap is the supremum over all primes, capturing the worst-case
obstruction. It equals zero if and only if `x` derives `y`. -/
noncomputable def freeEnergyGap
    (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞) (x y : S) : ℝ≥0∞ :=
  ⨆ (p : PrimeSpectrum S),
    spectralIndicator x p *
    (if p y = true then 0 else
      ⨅ (q : PrimeSpectrum S) (_ : q y = true), K p q)

/-- The **ε-regularized Schrödinger bridge cost** on the prime spectrum.
At temperature `ε > 0`, the bridge introduces:
- A thermal leakage cost `ε` on primes that already validate `y`
  (modeling the free energy of maintaining coherence)
- A shifted transport cost `K(p,q) + ε` for primes that don't validate `y`
  (modeling entropy production during transport)

As `ε → 0⁺`, the thermal fluctuations vanish and the Schrödinger cost
converges to the free energy gap, recovering the static transport picture. -/
noncomputable def schrodingerCost
    (ε : ℝ≥0) (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞) (x y : S) : ℝ≥0∞ :=
  ⨆ (p : PrimeSpectrum S),
    spectralIndicator x p *
    (if p y = true then (ε : ℝ≥0∞) else
      ⨅ (q : PrimeSpectrum S) (_ : q y = true), K p q + ε)

/-! ## Free Energy Gap Characterization -/

/-
When `x` derives `y`, the free energy gap vanishes: every prime that validates
`x` also validates `y`, so no transport is needed.
-/
theorem freeEnergyGap_eq_zero_of_derivable
    (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
    {x y : S} (h : derivable x y) :
    freeEnergyGap K x y = 0 := by
  refine' iSup_eq_bot.mpr _;
  intro p
  by_cases hp : p y = true;
  · aesop;
  · simp_all +decide [ spectralIndicator ];
    have := @forall_primeSpectrum_of_derivable S ‹_› x y h p; aesop;

/-
Helper: if p x = true, p y = false, and K has positive off-diagonal,
then the freeEnergyGap term at p is positive.
-/
lemma freeEnergyGap_term_pos
    (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
    (hK : IsMarkovKernel K)
    (x y : S) (p : PrimeSpectrum S)
    (hpx : p x = true) (hpy : p y = false) :
    0 < spectralIndicator x p *
      (if p y = true then 0 else ⨅ (q : PrimeSpectrum S) (_ : q y = true), K p q) := by
  -- Since $p x = true$, we have $spectralIndicator x p = 1$.
  simp [spectralIndicator, hpx];
  -- Since $p y = false$, the term simplifies to the infimum of $K p q$ over $q$ such that $q y = true$.
  have h_inf_pos : ∃ ε > 0, ∀ q, q y = true → K p q ≥ ε := by
    have h_inf_pos : ∀ q, q y = true → 0 < K p q := by
      intro q hqy;
      by_cases h : p = q <;> simp_all +decide [ IsMarkovKernel.off_diag_pos ];
    by_cases h_empty : ∀ q, q y = true → K p q = ⊤;
    · exact ⟨ 1, zero_lt_one, fun q hq => h_empty q hq ▸ le_top ⟩;
    · obtain ⟨q, hq⟩ : ∃ q, q y = true ∧ K p q ≠ ⊤ := by
        exact by push_neg at h_empty; exact h_empty;
      have h_inf_pos : ∃ ε ∈ Finset.image (fun q => K p q) (Finset.filter (fun q => q y = true) Finset.univ), ∀ q ∈ Finset.image (fun q => K p q) (Finset.filter (fun q => q y = true) Finset.univ), ε ≤ q := by
        exact ⟨ Finset.min' ( Finset.image ( fun q => K p q ) { q | q y = true } ) ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hq.1 ⟩ ) ⟩, Finset.min'_mem _ _, fun q hq => Finset.min'_le _ _ hq ⟩;
      obtain ⟨ ε, hε₁, hε₂ ⟩ := h_inf_pos;
      exact ⟨ ε, by obtain ⟨ q, hq₁, rfl ⟩ := Finset.mem_image.mp hε₁; exact h_inf_pos q ( Finset.mem_filter.mp hq₁ |>.2 ), fun q hq => hε₂ _ ( Finset.mem_image.mpr ⟨ q, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hq ⟩, rfl ⟩ ) ⟩;
  split_ifs ; simp_all +decide [ le_iInf_iff ];
  obtain ⟨ ε, ε_pos, hε ⟩ := h_inf_pos; refine' lt_of_lt_of_le ε_pos _; refine' le_iInf fun q => _; by_cases hq : q y = true <;> simp +decide [ hq, hε ] ;

/-- When `x` does not derive `y`, the free energy gap is strictly positive:
a separating prime forces positive transport cost through the Markov kernel. -/
theorem freeEnergyGap_pos_of_not_derivable
    (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
    (hK : IsMarkovKernel K)
    {x y : S} (h : ¬derivable x y) :
    0 < freeEnergyGap K x y := by
  unfold freeEnergyGap
  rw [lt_iSup_iff]
  -- Get separating prime from prime_separation
  have hsep := CoherentClosureProofSemiring.prime_separation x y h
  obtain ⟨hom_val, hcl, hx, hy⟩ := hsep
  refine ⟨⟨hom_val, hcl⟩, ?_⟩
  exact freeEnergyGap_term_pos K hK x y ⟨hom_val, hcl⟩ hx hy

/-- **Adequacy-Transport Bridge**: Derivability is equivalent to vanishing
free energy gap. This theorem bridges the syntactic notion of derivability
with the energetic notion of optimal spectral transport. -/
theorem derivable_iff_freeEnergyGap_zero
    (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
    (hK : IsMarkovKernel K)
    (x y : S) :
    derivable x y ↔ freeEnergyGap K x y = 0 := by
  constructor
  · exact freeEnergyGap_eq_zero_of_derivable K
  · intro h
    by_contra hnd
    exact absurd h (ne_of_gt (freeEnergyGap_pos_of_not_derivable K hK hnd))

/-! ## Sandwich Estimates -/

/-
Lower bound: the free energy gap is always at most the Schrödinger cost.
The regularization only adds non-negative terms.
-/
omit [Fintype (PrimeSpectrum S)] [DecidableEq (PrimeSpectrum S)] in
theorem freeEnergyGap_le_schrodingerCost
    (ε : ℝ≥0) (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
    (x y : S) :
    freeEnergyGap K x y ≤ schrodingerCost ε K x y := by
  refine' iSup_le fun p => _;
  refine' le_trans _ ( le_iSup _ p );
  split_ifs;
  · simp +decide [ spectralIndicator ];
  · gcongr;
    exact le_add_right le_rfl

/-
Upper bound: the Schrödinger cost is at most the free energy gap plus ε.
The regularization shifts each transport cost by at most ε.
-/
omit [Fintype (PrimeSpectrum S)] [DecidableEq (PrimeSpectrum S)] in
theorem schrodingerCost_le_freeEnergyGap_add
    (ε : ℝ≥0) (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
    (x y : S) :
    schrodingerCost ε K x y ≤ freeEnergyGap K x y + ε := by
  refine' iSup_le fun p => _;
  nontriviality;
  refine' le_trans _ ( add_le_add ( le_iSup _ p ) le_rfl );
  split_ifs <;> simp +decide [ *, spectralIndicator ];
  · split_ifs <;> simp +decide;
  · split_ifs <;> simp +decide [ *, ENNReal.iInf_add ]

/-
The Schrödinger cost equals the free energy gap when ε = 0.
-/
omit [Fintype (PrimeSpectrum S)] [DecidableEq (PrimeSpectrum S)] in
theorem schrodingerCost_zero
    (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞) (x y : S) :
    schrodingerCost 0 K x y = freeEnergyGap K x y := by
  refine' iSup_congr fun p => _;
  aesop

/-! ## Zero-Noise Convergence -/

omit [Fintype (PrimeSpectrum S)] [DecidableEq (PrimeSpectrum S)] in
/-- **Zero-Noise Convergence Theorem**: The ε-regularized Schrödinger bridge cost
converges to the free energy gap as ε → 0⁺. This is the variational convergence
(Γ-convergence in the finite-dimensional case) of the entropic regularization.

The proof uses the sandwich estimate:
  `freeEnergyGap ≤ schrodingerCost ε ≤ freeEnergyGap + ε`
combined with the squeeze theorem. -/
theorem schrodingerCost_tendsto_freeEnergyGap
    (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
    (_hK : IsMarkovKernel K)
    (x y : S) :
    Filter.Tendsto (fun ε : ℝ≥0 => schrodingerCost ε K x y)
      (nhdsWithin 0 (Set.Ioi 0)) (nhds (freeEnergyGap K x y)) := by
  apply tendsto_of_tendsto_of_tendsto_of_le_of_le
  · -- Lower bound: constant function tends to freeEnergyGap
    exact tendsto_const_nhds
  · -- Upper bound: freeEnergyGap + ε tends to freeEnergyGap + 0 = freeEnergyGap
    have h_coe : Filter.Tendsto (fun ε : ℝ≥0 => (ε : ℝ≥0∞))
        (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) :=
      (ENNReal.continuous_coe.tendsto 0).mono_left nhdsWithin_le_nhds
    have h_add : Filter.Tendsto (fun ε : ℝ≥0 => freeEnergyGap K x y + (ε : ℝ≥0∞))
        (nhdsWithin 0 (Set.Ioi 0)) (nhds (freeEnergyGap K x y + 0)) :=
      Filter.Tendsto.add tendsto_const_nhds h_coe
    simp only [add_zero] at h_add
    exact h_add
  · -- freeEnergyGap ≤ schrodingerCost
    intro ε; exact freeEnergyGap_le_schrodingerCost ε K x y
  · -- schrodingerCost ≤ freeEnergyGap + ε
    intro ε; exact schrodingerCost_le_freeEnergyGap_add ε K x y

/-! ## Main Theorem -/

/-- **Main Theorem: Prime-Spectral Schrödinger Bridge Characterization of Derivability**

Derivability in a coherent closure proof semiring is equivalent to the vanishing
of the Schrödinger bridge cost in the zero-noise limit on the prime spectrum.

This theorem identifies proof-theoretic derivability with a zero-noise stochastic
control problem: `x` derives `y` if and only if the minimal entropic action
for transporting the spectral signature of `x` to that of `y` collapses to zero.

The proof combines:
1. The adequacy theorem (derivability ↔ prime spectrum agreement)
2. The transport bridge (derivability ↔ vanishing free energy gap)
3. The zero-noise convergence (Schrödinger cost → free energy gap) -/
theorem derivable_iff_tendsto_schrodingerCost_zero
    {S : Type*}
    [CoherentClosureProofSemiring S]
    [Fintype (PrimeSpectrum S)]
    [DecidableEq (PrimeSpectrum S)]
    (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
    (hK : IsMarkovKernel K)
    (x y : S) :
    derivable x y ↔
      Filter.Tendsto (fun ε : ℝ≥0 => schrodingerCost ε K x y)
        (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) := by
  rw [derivable_iff_freeEnergyGap_zero K hK]
  constructor
  · intro h
    have h_conv := schrodingerCost_tendsto_freeEnergyGap K hK x y
    rwa [h] at h_conv
  · intro h
    have h_conv := schrodingerCost_tendsto_freeEnergyGap K hK x y
    have h_nebot : (nhdsWithin (0 : ℝ≥0) (Set.Ioi 0)).NeBot :=
      nhdsWithin_Ioi_neBot le_rfl
    exact tendsto_nhds_unique h_conv h

/-! ## Sequential Version -/

/-
The sequence `1/(n+1)` converges to 0 in `ℝ≥0∞`.
-/
lemma nnreal_inv_nat_tendsto_zero :
    Filter.Tendsto (fun n : ℕ => (↑(1 / (↑n + 1 : ℝ≥0)) : ℝ≥0∞)) Filter.atTop (nhds 0) := by
  -- The sequence $1/(n+1)$ tends to $0$ as $n$ tends to infinity.
  have h_seq : Filter.Tendsto (fun n : ℕ => (1 : ℝ) / (n + 1)) Filter.atTop (nhds 0) := by
    exact tendsto_one_div_add_atTop_nhds_zero_nat;
  convert ENNReal.tendsto_ofReal h_seq;
  · rw [ ENNReal.ofReal_div_of_pos ] <;> norm_cast ; norm_num;
    linarith;
  · norm_num

/-- Sequential version of the main theorem, using the sequence `1/(n+1)`. -/
theorem derivable_iff_schrodingerCost_vanishes_along_inv
    {S : Type*}
    [CoherentClosureProofSemiring S]
    [Fintype (PrimeSpectrum S)]
    [DecidableEq (PrimeSpectrum S)]
    (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
    (hK : IsMarkovKernel K)
    (x y : S) :
    derivable x y ↔
      Filter.Tendsto (fun n : ℕ => schrodingerCost (1 / (n + 1 : ℝ≥0)) K x y)
        Filter.atTop (nhds 0) := by
  rw [derivable_iff_freeEnergyGap_zero K hK]
  constructor
  · -- Forward: freeEnergyGap = 0 → schrodingerCost(1/(n+1)) → 0
    intro h
    apply tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds _ (fun _ => zero_le _)
    · intro n
      have := schrodingerCost_le_freeEnergyGap_add (1 / (↑n + 1 : ℝ≥0)) K x y
      simp only [h, zero_add] at this
      exact this
    · exact nnreal_inv_nat_tendsto_zero
  · -- Backward: schrodingerCost(1/(n+1)) → 0 → freeEnergyGap = 0
    intro h
    have h_le : ∀ n : ℕ, freeEnergyGap K x y ≤ schrodingerCost (1 / (↑n + 1)) K x y :=
      fun n => freeEnergyGap_le_schrodingerCost _ K x y
    exact le_antisymm (ge_of_tendsto' h h_le) (zero_le _)

end PrimeSpectralBridge