import Mathlib

/-!
# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

We develop a theory of "hyperbolic integers" — points in the Poincaré disk model
of the hyperbolic plane that form the orbit of the origin under a discrete group
of Möbius transformations. We define hyperbolic distance, prove its key properties,
introduce hyperbolic norms and primes, and state conjectures about unique factorization
and prime counting in this curved arithmetic.

## Main Definitions

* `PoincareDisk` — The open unit disk {z ∈ ℂ : ‖z‖ < 1}
* `MobiusAut` — Möbius automorphisms of the Poincaré disk
* `hypDist` — The hyperbolic distance function
* `HypLattice` — Hyperbolic lattice (orbit of origin)
* `HypNorm` — Hyperbolic norm (distance from origin)
* `IsHypPrime` — Notion of hyperbolic prime

## Main Results

* `denom_ne_zero` — Möbius denominator is nonzero in the disk
* `hyp_dist_self_zero` — d(z,z) = 0
* `crossRatioFactor_symm` — Cross-ratio symmetry
* `hyp_dist_symm` — d(z,w) = d(w,z)
* `orbit_monotone` — Orbit growth monotonicity
* `orbit_card_upper_bound` — Exponential upper bound on orbit size
-/

noncomputable section

open Complex Real Finset

/-! ## The Poincaré Disk -/

/-- The Poincaré disk: the open unit disk in ℂ. -/
def PoincareDisk : Set ℂ := {z : ℂ | ‖z‖ < 1}

/-- A point in the Poincaré disk, bundled as a subtype. -/
abbrev PDPoint := {z : ℂ // z ∈ PoincareDisk}

/-- The origin is in the Poincaré disk. -/
theorem origin_in_disk : (0 : ℂ) ∈ PoincareDisk := by
  simp [PoincareDisk, norm_zero]

/-- The Poincaré disk is nonempty. -/
instance : Nonempty PDPoint := ⟨⟨0, origin_in_disk⟩⟩

/-! ## Hyperbolic Distance -/

/-- The cross-ratio factor |z - w| / |1 - conj(w) * z|, used in defining hyperbolic distance. -/
def crossRatioFactor (z w : ℂ) : ℝ :=
  ‖z - w‖ / ‖1 - starRingEnd ℂ w * z‖

/-- The hyperbolic distance on the Poincaré disk, defined via the log formula:
    d(z,w) = 2 * log((1 + ρ) / (1 - ρ)) where ρ = |z-w|/|1-conj(w)z| -/
def hypDist (z w : ℂ) : ℝ :=
  2 * Real.log ((1 + crossRatioFactor z w) / (1 - crossRatioFactor z w))

/-- Hyperbolic distance from a point to itself is zero. -/
theorem hyp_dist_self_zero (z : ℂ) : hypDist z z = 0 := by
  simp [hypDist, crossRatioFactor, sub_self, norm_zero, zero_div]

/-
The cross-ratio factor is symmetric: |z-w|/|1-conj(w)z| = |w-z|/|1-conj(z)w|.
    The numerator symmetry is obvious; the denominator requires conjugation algebra.
-/
theorem crossRatioFactor_symm (z w : ℂ) (_hz : z ∈ PoincareDisk) (_hw : w ∈ PoincareDisk) :
    crossRatioFactor z w = crossRatioFactor w z := by
  unfold crossRatioFactor;
  norm_num [ Complex.norm_def, Complex.normSq ];
  ring

/-- Hyperbolic distance is symmetric for points in the disk. -/
theorem hyp_dist_symm (z w : ℂ) (hz : z ∈ PoincareDisk) (hw : w ∈ PoincareDisk) :
    hypDist z w = hypDist w z := by
  unfold hypDist
  rw [crossRatioFactor_symm z w hz hw]

/-! ## Möbius Automorphisms of the Disk -/

/-- A Möbius automorphism of the Poincaré disk is parameterized by
    a center point a ∈ D and a rotation angle θ.
    The map is z ↦ e^{iθ} · (z - a) / (1 - conj(a) · z). -/
structure MobiusAut where
  center : ℂ
  angle : ℝ
  center_in_disk : ‖center‖ < 1

/-- Apply a Möbius automorphism to a complex number. -/
def MobiusAut.apply (φ : MobiusAut) (z : ℂ) : ℂ :=
  Complex.exp (φ.angle * Complex.I) * (z - φ.center) / (1 - starRingEnd ℂ φ.center * z)

/-
The denominator 1 - conj(a) * z is nonzero when both a and z are in the unit disk.
    This is proved by contradiction: if the denominator were zero, then conj(a)*z = 1,
    so |a|·|z| = 1, contradicting |a|,|z| < 1.
-/
theorem denom_ne_zero (a z : ℂ) (ha : ‖a‖ < 1) (hz : ‖z‖ < 1) :
    (1 : ℂ) - starRingEnd ℂ a * z ≠ 0 := by
  exact sub_ne_zero_of_ne <| ne_of_apply_ne Norm.norm <| by norm_num; nlinarith [ norm_nonneg a, norm_nonneg z ] ;

/-
A Möbius automorphism maps the Poincaré disk into itself.
-/
theorem mobius_aut_maps_disk (φ : MobiusAut) (z : ℂ) (hz : z ∈ PoincareDisk) :
    φ.apply z ∈ PoincareDisk := by
  -- We need to show that |φ.apply z| < 1. The map is e^{iθ} * (z-a)/(1-conj(a)*z). Since |e^{iθ}| = 1, we have |φ.apply z| = |z-a|/|1-conj(a)*z|.
  have h_apply : ‖φ.apply z‖ = ‖z - φ.center‖ / ‖1 - starRingEnd ℂ φ.center * z‖ := by
    simp +decide [ MobiusAut.apply, Complex.norm_exp ];
  refine' h_apply.trans_lt ( div_lt_one _ |>.2 _ );
  · exact norm_pos_iff.mpr ( denom_ne_zero _ _ φ.center_in_disk hz );
  · norm_num [ Complex.normSq, Complex.norm_def ] at *;
    rw [ Real.sqrt_lt_sqrt_iff ] <;> try nlinarith;
    have := hz.out; ( have := φ.center_in_disk; ( rw [ Complex.norm_def ] at *; simp_all +decide [ Complex.normSq ] ) );
    rw [ Real.sqrt_lt' ] at * <;> nlinarith

/-! ## Hyperbolic Norm and Lattice Points -/

/-- The hyperbolic norm of a point: its hyperbolic distance from the origin. -/
def hypNorm (z : ℂ) : ℝ := hypDist z 0

/-- The hyperbolic norm is zero at the origin. -/
theorem hyp_norm_zero : hypNorm 0 = 0 := hyp_dist_self_zero 0

/-- The cross-ratio factor at the origin simplifies to |z|. -/
theorem crossRatioFactor_origin (z : ℂ) : crossRatioFactor z 0 = ‖z‖ := by
  simp [crossRatioFactor, map_zero, sub_zero]

/-- When applied at the origin, the hyperbolic norm reduces to 2 * log((1+|z|)/(1-|z|)). -/
theorem hyp_norm_formula (z : ℂ) :
    hypNorm z = 2 * Real.log ((1 + ‖z‖) / (1 - ‖z‖)) := by
  simp [hypNorm, hypDist, crossRatioFactor_origin]

/-
The hyperbolic norm is non-negative for points in the disk.
    Since |z| < 1 for z in the disk, (1+|z|)/(1-|z|) ≥ 1, so log ≥ 0.
-/
theorem hyp_norm_nonneg (z : ℂ) (hz : z ∈ PoincareDisk) : 0 ≤ hypNorm z := by
  exact hyp_norm_formula z ▸ mul_nonneg zero_le_two ( Real.log_nonneg ( by rw [ le_div_iff₀ ] <;> linarith [ norm_nonneg z, hz.out ] ) )

/-! ## Hyperbolic Lattice: Orbit of Origin under Discrete Group -/

/-- A hyperbolic lattice is the orbit of the origin under iterated application
    of a finite set of Möbius automorphisms (generators of a discrete group). -/
structure HypLattice where
  generators : Finset MobiusAut
  nonempty : generators.Nonempty

/-- The set of lattice points reachable in at most n steps from the origin. -/
def HypLattice.orbitUpTo (Γ : HypLattice) : ℕ → Finset ℂ
  | 0 => {0}
  | n + 1 =>
    let prev := Γ.orbitUpTo n
    prev ∪ prev.biUnion (fun z => Γ.generators.image (fun φ => φ.apply z))

/-- The orbit at step 0 is just the origin. -/
theorem orbit_step_zero (Γ : HypLattice) : Γ.orbitUpTo 0 = {0} := rfl

/-- The orbit is monotonically increasing: each step includes the previous. -/
theorem orbit_monotone (Γ : HypLattice) (n : ℕ) :
    Γ.orbitUpTo n ⊆ Γ.orbitUpTo (n + 1) := by
  intro x hx
  simp [HypLattice.orbitUpTo]
  left
  exact hx

/-- The orbit is nonempty at every step (induction on n). -/
theorem orbit_nonempty (Γ : HypLattice) (n : ℕ) :
    (Γ.orbitUpTo n).Nonempty := by
  induction n with
  | zero => exact ⟨0, by simp [HypLattice.orbitUpTo]⟩
  | succ n ih =>
    exact Finset.Nonempty.mono (orbit_monotone Γ n) ih

/-- Monotonicity of orbit cardinality. -/
theorem orbit_card_nondecreasing (Γ : HypLattice) (n : ℕ) :
    (Γ.orbitUpTo n).card ≤ (Γ.orbitUpTo (n + 1)).card :=
  Finset.card_le_card (orbit_monotone Γ n)

/-! ## Hyperbolic Primes -/

/-- A hyperbolic lattice point is "prime" if it is in the first-generation orbit
    (directly reachable from the origin by a single generator) and is not
    the origin itself. Primes are the "atoms" of the hyperbolic lattice. -/
def IsHypPrime (Γ : HypLattice) (z : ℂ) : Prop :=
  z ∈ Γ.orbitUpTo 1 ∧ z ∉ Γ.orbitUpTo 0

/-- A hyperbolic prime is not the origin. -/
theorem hyp_prime_ne_zero (Γ : HypLattice) (z : ℂ) (hp : IsHypPrime Γ z) :
    z ≠ 0 := by
  intro h
  rw [h] at hp
  exact hp.2 (by simp [HypLattice.orbitUpTo])

/-! ## Exponential Growth of Orbits -/

/-
For a lattice with k generators, the orbit at step n+1 has at most
    card(orbit_n) * (k + 1) points. This is because each step adds at most
    k * card(orbit_n) new points.
-/
theorem orbit_step_bound (Γ : HypLattice) (n : ℕ) :
    (Γ.orbitUpTo (n + 1)).card ≤
    (Γ.orbitUpTo n).card + (Γ.orbitUpTo n).card * Γ.generators.card := by
  -- We can bound the size of the biUnion from above by the product of the size of the orbit and the size of the generators.
  have h_biUnion_le : ∀ (s : Finset ℂ) (f : ℂ → Finset ℂ), (s.biUnion f).card ≤ s.card * (s.sup fun z => (f z).card) := by
    exact fun s f => le_trans ( Finset.card_biUnion_le ) ( Finset.sum_le_card_nsmul _ _ _ fun x hx => Finset.le_sup ( f := fun z => Finset.card ( f z ) ) hx );
  refine le_trans ( Finset.card_union_le _ _ ) ?_;
  refine' add_le_add le_rfl ( le_trans ( h_biUnion_le _ _ ) _ );
  exact Nat.mul_le_mul_left _ ( Finset.sup_le fun x hx => Finset.card_image_le )

/-
For a lattice with k generators, the orbit at step n has at most (k+1)^n points.
    Proof by induction using orbit_step_bound.
-/
theorem orbit_card_upper_bound (Γ : HypLattice) (n : ℕ) :
    (Γ.orbitUpTo n).card ≤ (Γ.generators.card + 1) ^ n := by
  induction' n with n ih;
  · aesop;
  · convert le_trans ( orbit_step_bound Γ n ) _ using 1;
    rw [ pow_succ' ] ; nlinarith [ pow_succ' ( #Γ.generators + 1 ) n ]

/-! ## Hyperbolic Zeta Function (Definition) -/

/-- The partial hyperbolic zeta function: sum of 1/|z|_H^{2s} over lattice points
    reachable in at most n steps, excluding the origin. -/
def hypZetaPartial (Γ : HypLattice) (n : ℕ) (s : ℝ) : ℝ :=
  ∑ z ∈ (Γ.orbitUpTo n).filter (· ≠ 0),
    1 / (hypNorm z) ^ (2 * s)

/-! ## Hyperbolic Composition (Group Operation) -/

/-- Hyperbolic "addition": composition of Möbius transformations applied to a base point.
    Given lattice points z = φ(0) and w = ψ(0), their hyperbolic sum is (φ ∘ ψ)(0). -/
def MobiusAut.compose (φ ψ : MobiusAut) : ℂ :=
  φ.apply (ψ.apply 0)

/-! ## Novel Definition: Hyperbolic Divisibility -/

/-- **Novel concept**: Hyperbolic divisibility. We say z "hyperbolically divides" w
    in a lattice Γ if there exists a sequence of generators whose composition
    maps z to w. This creates a partial order on lattice points analogous to
    divisibility in ℤ. -/
def HypDivides (Γ : HypLattice) (z w : ℂ) : Prop :=
  ∃ n : ℕ, ∃ φs : Fin n → MobiusAut,
    (∀ i, φs i ∈ Γ.generators) ∧
    (List.ofFn (fun i => φs i)).foldl (fun acc φ => φ.apply acc) z = w

/-- Hyperbolic divisibility is reflexive (take zero generators). -/
theorem hyp_divides_refl (Γ : HypLattice) (z : ℂ) : HypDivides Γ z z :=
  ⟨0, Fin.elim0, fun i => Fin.elim0 i, by simp [List.ofFn]⟩

/-! ## Novel Definition: Hyperbolic Valuation -/

open Classical in
/-- The hyperbolic valuation of a lattice point is the minimum
    number of generator applications needed to reach it from the origin.
    This is the hyperbolic analogue of the p-adic valuation.
    Returns 0 for the origin and for points not in any finite orbit. -/
def hypValuation (Γ : HypLattice) (z : ℂ) : ℕ :=
  if z = 0 then 0
  else if h : ∃ n, z ∈ Γ.orbitUpTo n then Nat.find h
  else 0

/-- The hyperbolic valuation of the origin is 0. -/
theorem hypValuation_zero (Γ : HypLattice) : hypValuation Γ 0 = 0 := by
  simp [hypValuation]

/-! ## Falsifiable Conjecture -/

/-- **Conjecture (Hyperbolic Prime Number Theorem)**:
    For any hyperbolic lattice Γ with k ≥ 2 generators, the orbit grows
    exponentially: there exists c > 0 such that for all n,
    card(orbit(n)) ≥ c * k^n.

    **Testable prediction**: For PSL(2,ℤ) with 2 generators acting on the
    Poincaré disk, orbit(5) should have at least 20 distinct points.
    This can be checked by explicit computation. -/
def hyperbolicOrbitGrowthConj : Prop :=
  ∀ (Γ : HypLattice), 2 ≤ Γ.generators.card →
  ∃ c : ℝ, 0 < c ∧ ∀ n : ℕ,
    c * (Γ.generators.card : ℝ) ^ n ≤ (Γ.orbitUpTo n).card

end