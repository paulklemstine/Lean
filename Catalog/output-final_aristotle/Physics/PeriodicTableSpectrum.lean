import Mathlib
import Physics.AngularMomentum

/-!
# Elements as Eigenvalues: Shell Structure of a Diagonal Hamiltonian

This file develops the *spectral* reading of shell structure that underlies both
the electronic periodic table and the nuclear shell model.  The unifying idea is
that a shell-structured Hamiltonian is, in an appropriate basis, a **diagonal
operator**, so the "elements" (closed shells / noble-gas and magic configurations)
are exactly the *cumulative degeneracies of its eigenvalues*.

Two shell models are treated side by side, each producing a closed-form
"cumulative filling" polynomial:

* **Hydrogenic (Coulomb) shells.**  The `n`-th shell has degeneracy `2n²`, coming
  from summing the `2l+1` magnetic sublevels over the sub-shells `l = 0,…,n-1`
  (an identity `∑ (2l+1) = n²`) and doubling for spin.  The cumulative fillings
  are `2, 10, 28, 60, 110, …`, governed by `∑_{k=1}^n 2k² = n(n+1)(2n+1)/3`.

* **Isotropic harmonic-oscillator shells (nuclear model).**  The `N`-th level has
  degeneracy `(N+1)(N+2)`, and the cumulative fillings
  `2, 8, 20, 40, 70, 112, …` are governed by
  `∑_{N=0}^{n} (N+1)(N+2) = (n+1)(n+2)(n+3)/3`.  Its first three closed shells,
  `2, 8, 20`, are exactly the first three nuclear *magic numbers*.

Finally we make the spectral picture literal: the shell energies are placed on the
diagonal of a Hermitian matrix, and each standard basis vector is exhibited as an
eigenvector whose eigenvalue is the corresponding shell energy.  This is the sense
in which "elements are eigenvalues": the atom's configuration is read off from the
spectrum and multiplicities of a self-adjoint operator.

The subshell-counting identity is tied to the catalog development
`Physics/AngularMomentum.lean`: the `2l+1` values counted here are precisely the
magnetic quantum numbers `m ∈ [-l, l]` whose azimuthal eigenfunctions
`azimuthalExp m` are proved `2π`-periodic there.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Shell "periodicity" is not a chemical accident but a
degeneracy phenomenon: the closed-shell (noble-gas / magic) numbers are cumulative
sums of eigenvalue degeneracies of a shell Hamiltonian.  Two candidate degeneracy
laws — Coulomb `2n²` and oscillator `(N+1)(N+2)` — should each collapse to a single
cubic filling polynomial, and the oscillator law should reproduce the small nuclear
magic numbers `2, 8, 20`.

EXPERIMENT (Experimenter).  Proven below by induction / cardinality:
* `angularCount_eq_sq` : `∑_{l<n} (2l+1) = n²` (the angular-momentum sum rule);
* `shellDeg_eq_two_mul_angularCount` : `2n² = 2·∑(2l+1)` (spin doubling);
* `nobleGas_closed` : `3·(∑_{k<n} 2(k+1)²) = n(n+1)(2n+1)`;
* `magicHO_closed`  : `3·(∑_{N≤n} (N+1)(N+2)) = (n+1)(n+2)(n+3)`;
* `nobleGas_strictMono`, `magicHO_strictMono` : shells strictly grow;
* `shellHamiltonian_isHermitian`, `_trace`, `basisVec_isEigen` : the diagonal
  Hamiltonian is self-adjoint, its trace is the total shell energy, and standard
  basis vectors are eigenvectors with the shell energies as eigenvalues;
* `subshell_card`, `subshell_eigenfunctions_periodic` : the `2l+1` count equals the
  number of magnetic quantum numbers `m ∈ [-l,l]`, each giving a `2π`-periodic
  azimuthal eigenfunction (using the catalog file `Physics/AngularMomentum.lean`).

ANALYSIS (Analyst).  Both models are "true but the physics is only heuristic":
the *mathematics* (degeneracy sums, cubic fillings, diagonal spectrum) is exact,
while the *identification* with real atomic numbers is model-dependent.  The
Coulomb law gives `2,10,28,60,110` — the correct pattern for an *n²*-degenerate
spectrum but NOT the observed noble gases (`2,10,18,36,…`), because real filling
follows the Madelung `(n+l)` rule rather than pure `n`-shells.  The oscillator law
reproduces `2,8,20` but overshoots at `40,70` where the empirical magic numbers are
`28,50` (spin–orbit splitting, absent from the bare oscillator).

CRITIQUE (Critic).  Every main theorem uses induction, cardinality, or an explicit
eigenvector computation — none is `True`, definitional, or a bare `decide`.  The
`example`s that evaluate the small fillings are illustrations, not load-bearing
results.  Boundary cases are recorded: the Coulomb fillings deviate from observed
noble gases beyond `Z=10`, and the oscillator magic numbers deviate beyond `20`;
these are documented as genuine limits of the model, not defects of the theorems.

SYNTHESIS (PI).  Shell structure = eigenvalue degeneracy structure of a diagonal
Hamiltonian.  The catalog's angular eigenfunctions supply the `2l+1` multiplicities;
number-theoretic summation supplies the cubic filling laws; linear algebra supplies
the literal spectrum.  "Chemistry is applied spectral theory" holds exactly at the
level of degeneracy bookkeeping.
-/

open Finset

namespace PeriodicTableSpectrum

/-! ## Angular-momentum sum rule and shell degeneracies -/

/-- Number of magnetic sublevels summed over the sub-shells `l = 0,…,n-1`:
`∑_{l<n} (2l+1)`. -/
def angularCount (n : ℕ) : ℕ := ∑ l ∈ Finset.range n, (2 * l + 1)

/-- Degeneracy of the `n`-th Coulomb (hydrogenic) shell, `2n²` (spin included). -/
def shellDeg (n : ℕ) : ℕ := 2 * n ^ 2

/-- **Angular-momentum sum rule.** The magnetic sublevels of the sub-shells
`l = 0,…,n-1` number exactly `n²`. -/
theorem angularCount_eq_sq (n : ℕ) : angularCount n = n ^ 2 := by
  unfold angularCount
  induction n with
  | zero => simp
  | succ k ih => rw [Finset.sum_range_succ, ih]; ring

/-- Spin doubling: the Coulomb shell degeneracy `2n²` is twice the angular count. -/
theorem shellDeg_eq_two_mul_angularCount (n : ℕ) :
    shellDeg n = 2 * angularCount n := by
  rw [shellDeg, angularCount_eq_sq]

/-! ## Cumulative Coulomb fillings (noble-gas pattern) -/

/-- Cumulative filling of the first `n` Coulomb shells: `∑_{k=1}^{n} 2k²`. -/
def nobleGas (n : ℕ) : ℕ := ∑ k ∈ Finset.range n, shellDeg (k + 1)

/-- The added electrons when opening the `(n+1)`-st shell. -/
theorem nobleGas_succ (n : ℕ) : nobleGas (n + 1) = nobleGas n + 2 * (n + 1) ^ 2 := by
  rw [nobleGas, Finset.sum_range_succ]; rfl

/-- **Closed form for the Coulomb fillings** (Faulhaber, `p=2`):
`3·(∑_{k=1}^{n} 2k²) = n(n+1)(2n+1)`.  For `n = 1,…,5` this yields
`2, 10, 28, 60, 110`. -/
theorem nobleGas_closed (n : ℕ) :
    3 * nobleGas n = n * (n + 1) * (2 * n + 1) := by
  unfold nobleGas shellDeg
  induction n with
  | zero => simp
  | succ k ih => rw [Finset.sum_range_succ, Nat.mul_add, ih]; ring

/-- The cumulative Coulomb fillings strictly increase (each new shell is nonempty). -/
theorem nobleGas_strictMono : StrictMono nobleGas := by
  apply strictMono_nat_of_lt_succ
  intro n
  rw [nobleGas_succ]
  have : 0 < 2 * (n + 1) ^ 2 := by positivity
  omega

/-! ## Cumulative harmonic-oscillator fillings (nuclear magic numbers) -/

/-- Degeneracy of the `N`-th isotropic 3D harmonic-oscillator level, `(N+1)(N+2)`. -/
def hoDeg (N : ℕ) : ℕ := (N + 1) * (N + 2)

/-- Cumulative filling of the first `n+1` oscillator levels: `∑_{N=0}^{n} (N+1)(N+2)`. -/
def magicHO (n : ℕ) : ℕ := ∑ N ∈ Finset.range (n + 1), hoDeg N

/-- **Closed form for the oscillator fillings:**
`3·(∑_{N=0}^{n} (N+1)(N+2)) = (n+1)(n+2)(n+3)`.  For `n = 0,…,5` this yields
`2, 8, 20, 40, 70, 112`; the first three, `2, 8, 20`, are nuclear magic numbers. -/
theorem magicHO_closed (n : ℕ) :
    3 * magicHO n = (n + 1) * (n + 2) * (n + 3) := by
  unfold magicHO hoDeg
  induction n with
  | zero => simp
  | succ k ih => rw [Finset.sum_range_succ, Nat.mul_add, ih]; ring

/-- The cumulative oscillator fillings strictly increase. -/
theorem magicHO_strictMono : StrictMono magicHO := by
  apply strictMono_nat_of_lt_succ
  intro n
  have hstep : magicHO (n + 1) = magicHO n + (n + 2) * (n + 3) := by
    rw [magicHO, Finset.sum_range_succ]; rfl
  have : 0 < (n + 2) * (n + 3) := by positivity
  omega

/-- Both models agree on the very first closed shell (helium / the `Z=2` magic
number): a genuine coincidence of the two degeneracy laws. -/
theorem first_shell_agree : nobleGas 1 = magicHO 0 := by decide

/-! ## The diagonal shell Hamiltonian: elements as eigenvalues -/

/-- Hydrogenic shell energies `E_n = -1/(n+1)²` (Rydberg form, indexed from `0`). -/
noncomputable def shellEnergy (n : ℕ) : ℝ := -1 / ((n : ℝ) + 1) ^ 2

/-- The shell Hamiltonian on `d` levels: the diagonal operator with the shell
energies on its diagonal. -/
noncomputable def shellHamiltonian (d : ℕ) : Matrix (Fin d) (Fin d) ℝ :=
  Matrix.diagonal (fun i : Fin d => shellEnergy i)

/-- The shell Hamiltonian is self-adjoint (Hermitian). -/
theorem shellHamiltonian_isHermitian (d : ℕ) :
    (shellHamiltonian d).IsHermitian :=
  Matrix.isHermitian_diagonal _

/-- The trace of the shell Hamiltonian is the total shell energy `∑ E_n`. -/
theorem shellHamiltonian_trace (d : ℕ) :
    (shellHamiltonian d).trace = ∑ i : Fin d, shellEnergy i := by
  simp [shellHamiltonian, Matrix.trace_diagonal]

/-- **Elements as eigenvalues.** Each standard basis vector `e_i` is an eigenvector
of the shell Hamiltonian, with eigenvalue the `i`-th shell energy.  The spectrum of
the Hamiltonian is thus exactly the multiset of shell energies. -/
theorem basisVec_isEigen (d : ℕ) (i : Fin d) :
    (shellHamiltonian d).mulVec (Pi.single i (1 : ℝ))
      = shellEnergy i • (Pi.single i (1 : ℝ) : Fin d → ℝ) := by
  funext j
  by_cases h : i = j
  · subst h; simp [shellHamiltonian, Matrix.mulVec_diagonal]
  · simp [shellHamiltonian, Matrix.mulVec_diagonal, Ne.symm h]

/-! ## Bridge to the catalog: magnetic sublevels are the `2l+1` count

The angular sum rule `∑ (2l+1) = n²` counts, sub-shell by sub-shell, the magnetic
quantum numbers `m ∈ {-l, …, l}`.  We connect this to the azimuthal eigenfunctions
`azimuthalExp` of `Physics/AngularMomentum.lean`. -/

/-- The sub-shell of angular momentum `l` has exactly `2l+1` magnetic quantum
numbers `m ∈ [-l, l]`. -/
theorem subshell_card (l : ℕ) :
    (Finset.Icc (-(l : ℤ)) (l : ℤ)).card = 2 * l + 1 := by
  rw [Int.card_Icc]; omega

/-- Each of the `2l+1` azimuthal eigenfunctions in the sub-shell `l` is
`2π`-periodic — the catalog's periodicity applied uniformly across the whole
sub-shell.  Together with `subshell_card` this says the shell degeneracy is a count
of genuine (single-valued) angular eigenstates. -/
theorem subshell_eigenfunctions_periodic (l : ℕ) (φ : ℝ) :
    ∀ m ∈ Finset.Icc (-(l : ℤ)) (l : ℤ),
      azimuthalExp m (φ + 2 * Real.pi) = azimuthalExp m φ :=
  fun m _ => azimuthal_eigenfunction_periodic m φ

/-! ## Examples (PEGB: concrete instantiation)

The Coulomb fillings `2,10,28,60,110` and the oscillator fillings `2,8,20,40,70,112`
are recovered from the closed forms; the small magic numbers are checked directly. -/

-- Coulomb fillings for n = 1,…,5.
example : nobleGas 1 = 2 ∧ nobleGas 2 = 10 ∧ nobleGas 3 = 28 ∧
    nobleGas 4 = 60 ∧ nobleGas 5 = 110 := by decide

-- Oscillator fillings for n = 0,…,5 (first three are nuclear magic numbers 2,8,20).
example : magicHO 0 = 2 ∧ magicHO 1 = 8 ∧ magicHO 2 = 20 ∧
    magicHO 3 = 40 ∧ magicHO 4 = 70 ∧ magicHO 5 = 112 := by decide

-- Shell degeneracies 2,8,18,32,50 (the "period lengths").
example : shellDeg 1 = 2 ∧ shellDeg 2 = 8 ∧ shellDeg 3 = 18 ∧
    shellDeg 4 = 32 ∧ shellDeg 5 = 50 := by decide

#check @nobleGas_closed
#check @magicHO_closed
#check @basisVec_isEigen
#check @subshell_eigenfunctions_periodic
#eval (List.range 5).map (fun n => nobleGas (n + 1))   -- [2, 10, 28, 60, 110]
#eval (List.range 6).map magicHO                        -- [2, 8, 20, 40, 70, 112]

/-! ## Generalizations and boundaries (PEGB)

**Generalization.** Both filling laws are the `p=2` Faulhaber sums for two shifted
quadratic degeneracy sequences; the same induction proves a cubic closed form for
*any* affine-quadratic degeneracy `a·k² + b·k + c`, giving a two-parameter family of
"periodic tables" indexed by the degeneracy polynomial.  The diagonal-Hamiltonian
construction generalizes verbatim to any energy function `ℕ → ℝ` and any finite
truncation, and to self-adjoint operators on separable Hilbert spaces whose spectrum
is pure point.

**Boundary / counterexample to the naive model.** The Coulomb law predicts closed
shells `2,10,28,60,110`, but the *observed* noble gases are `2,10,18,36,54,86`: the
model is exact as a statement about an `n²`-degenerate spectrum yet fails as a
prediction of chemistry beyond `Z=10`, because real filling obeys the Madelung
`(n+l)` ordering, not pure `n`-shells.  Likewise the oscillator magic numbers match
`2,8,20` but diverge (`40,70` vs. empirical `28,50`) once spin–orbit coupling — a
term absent from the bare diagonal model — lifts the degeneracies.  These are the
precise limits of "the periodic table is a spectrum". -/

end PeriodicTableSpectrum