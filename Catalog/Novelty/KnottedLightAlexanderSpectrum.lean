import Mathlib
import Tropical.CyclotomicKnotSpectra

/-!
# Alexander Spectra of Torus-Knotted Light

For the torus-knot family `T(2,p)`, the Alexander polynomial is an alternating
geometric sum.  Its evaluation on equally spaced optical phases admits an exact
arithmetic classification: for odd prime `p`, the allowed residues are precisely
the units modulo `2p`.  This identifies the spectral selection rule with
coprimality, rather than merely listing isolated roots.

The same analysis exposes a boundary of the root-of-unity proposal.  The
figure-eight polynomial has real reciprocal roots away from the unit circle, so
its real roots cannot be interpreted as angular residues by reducing them modulo
one.
-/

open Polynomial

noncomputable section

namespace KnottedLightAlexanderSpectrum

/-- The `l`-th phase on the `n`-point angular grid. -/
def angularPhase (n l : ℕ) : ℂ :=
  Complex.exp (2 * Real.pi * Complex.I * (l : ℂ) / (n : ℂ))

/-
The first angular phase is a primitive root whenever the grid is nonempty.
-/
lemma angularPhase_one_isPrimitive (n : ℕ) (hn : 0 < n) :
    IsPrimitiveRoot (angularPhase n 1) n := by
  convert Complex.isPrimitiveRoot_exp n hn.ne' using 1;
  unfold angularPhase; ring;

/-
Angular phases are powers of the first phase.
-/
lemma angularPhase_eq_pow (n l : ℕ) :
    angularPhase n l = angularPhase n 1 ^ l := by
  unfold angularPhase; ring_nf;
  rw [ ← Complex.exp_nat_mul ] ; ring

/-
The mapped Alexander polynomial of `T(2,p)` vanishes at an angular phase
exactly when that phase is primitive of order `2p`.
-/
theorem alexander_isRoot_angularPhase_iff_primitive (p l : ℕ)
    (hp : p.Prime) (hp2 : p ≠ 2) :
    (((alexanderTorusPoly p).map (Int.castRingHom ℂ)).IsRoot (angularPhase (2 * p) l)) ↔
      IsPrimitiveRoot (angularPhase (2 * p) l) (2 * p) := by
  -- Rewrite alexanderTorusPoly using alexander_eq_cyclotomic_bridge.
  have h_alexander : map (Int.castRingHom ℂ) (alexanderTorusPoly p) = cyclotomic (2 * p) ℂ := by
    rw [ alexander_eq_cyclotomic_bridge p hp hp2, Polynomial.map_cyclotomic ];
  rw [ h_alexander, Polynomial.isRoot_cyclotomic_iff_charZero ];
  linarith [ hp.pos ]

/-
**Exact OAM residue classification.**  For an odd prime `p`, evaluation of
the `T(2,p)` Alexander polynomial on the `2p`-point phase grid vanishes exactly
at residues coprime to `2p`.
-/
theorem alexander_oam_iff_coprime (p l : ℕ) (hp : p.Prime) (hp2 : p ≠ 2) :
    (((alexanderTorusPoly p).map (Int.castRingHom ℂ)).IsRoot (angularPhase (2 * p) l)) ↔
      Nat.Coprime l (2 * p) := by
  convert alexander_isRoot_angularPhase_iff_primitive p l hp hp2 using 1;
  rw [ angularPhase_eq_pow, IsPrimitiveRoot.pow_iff_coprime ];
  · exact angularPhase_one_isPrimitive _ ( Nat.mul_pos two_pos hp.pos );
  · linarith [ hp.pos ]

/-
The trefoil selection rule: a phase indexed by `l` is allowed exactly when
`l` is coprime to six.
-/
theorem trefoil_oam_iff_coprime (l : ℕ) :
    (((alexanderTorusPoly 3).map (Int.castRingHom ℂ)).IsRoot (angularPhase 6 l)) ↔
      Nat.Coprime l 6 := by
  convert alexander_oam_iff_coprime 3 l ( by norm_num ) ( by norm_num ) using 1

/-
The cinquefoil selection rule: a phase indexed by `l` is allowed exactly when
`l` is coprime to ten.
-/
theorem cinquefoil_oam_iff_coprime (l : ℕ) :
    (((alexanderTorusPoly 5).map (Int.castRingHom ℂ)).IsRoot (angularPhase 10 l)) ↔
      Nat.Coprime l 10 := by
  convert alexander_oam_iff_coprime 5 l ( by decide ) ( by decide ) using 1

/-
In one fundamental period, the trefoil has exactly the residues `1` and `5`.
-/
theorem trefoil_residues (l : ℕ) (hl : l < 6) :
    (((alexanderTorusPoly 3).map (Int.castRingHom ℂ)).IsRoot (angularPhase 6 l)) ↔
      l = 1 ∨ l = 5 := by
  convert alexander_oam_iff_coprime 3 l _ _ using 1;
  · interval_cases l <;> trivial;
  · norm_num;
  · norm_num

/-
In one fundamental period, the cinquefoil has exactly the residues
`1, 3, 7, 9`.
-/
theorem cinquefoil_residues (l : ℕ) (hl : l < 10) :
    (((alexanderTorusPoly 5).map (Int.castRingHom ℂ)).IsRoot (angularPhase 10 l)) ↔
      l = 1 ∨ l = 3 ∨ l = 7 ∨ l = 9 := by
  convert cinquefoil_oam_iff_coprime l using 1;
  interval_cases l <;> trivial

/-- The figure-eight Alexander polynomial over the complex numbers. -/
def figureEightAlexander : ℂ → ℂ := fun z => z ^ 2 - 3 * z + 1

/-
A unit-modulus root of the figure-eight polynomial would force an impossible
real-part equation.  Thus its Alexander roots supply no root-of-unity channels.
-/
theorem figureEight_no_unitCircle_root (z : ℂ) (hz : ‖z‖ = 1) :
    figureEightAlexander z ≠ 0 := by
  unfold figureEightAlexander;
  contrapose! hz; simp_all +decide [ Complex.norm_def, Complex.normSq ];
  norm_num [ Complex.ext_iff, sq ] at * ; nlinarith

/-- Consequently no point on any angular grid is a figure-eight root. -/
theorem figureEight_no_angularPhase_root (n l : ℕ) :
    figureEightAlexander (angularPhase n l) ≠ 0 := by
  apply figureEight_no_unitCircle_root
  unfold angularPhase
  norm_num [Complex.norm_exp]

-- !-- Lab Notes -- !--
/-
## Hypothesis

The isolated trefoil and cinquefoil channels should be instances of a uniform
selection rule for `T(2,p)`: the angular indices that survive Alexander
filtering are exactly the invertible residues modulo `2p`.  In contrast, the
real roots of the figure-eight polynomial should not define angular channels.

## Experiment

The torus Alexander polynomial was identified with the `2p`-th cyclotomic
polynomial, and angular phases were rewritten as powers of one primitive phase.
The primitive-power criterion then converted polynomial vanishing into the
single arithmetic condition `gcd(l,2p)=1`.  Direct bounded arithmetic recovered
`{1,5}` for the trefoil and `{1,3,7,9}` for the cinquefoil.  For the figure-eight,
combining its quadratic equation with unit modulus forces a real-part value
outside the unit disk.

## Analysis

The successful torus-knot rule is structural: periodicity, channel count, and
Galois symmetry all arise from the unit group modulo `2p`.  The figure-eight
proposal fails for a definitional reason, not numerical precision: reducing a
positive real polynomial root modulo one does not turn that root into the phase
at which the polynomial is evaluated.

## Critique

The conclusions concern the proposed Alexander-root spectral model, not a
derivation from Maxwell's equations.  The primality assumption is essential for
identifying the full alternating polynomial with one cyclotomic factor; composite
odd parameters split into several cyclotomic strata.  The zero-size angular grid
is harmless under totalized division and still yields no figure-eight root.

## Synthesis

For prime torus knots, Alexander filtering of angular phases is exactly modular
coprimality.  This bridges knot polynomials, cyclotomic Galois theory, and optical
angular indexing while sharply separating cyclotomic knots from the figure-eight
knot's off-circle root geometry.
-/

end KnottedLightAlexanderSpectrum