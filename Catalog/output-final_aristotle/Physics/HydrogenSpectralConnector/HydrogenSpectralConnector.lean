import Mathlib

/-!
# Hydrogen spectral data and the parity graph of dipole transitions

This file gives a self-contained formal model of three rigorous pieces of the
hydrogen spectral picture in Rydberg units:

* the spectral set `{-1/n² | n > 0} ∪ [0,∞)` and its threshold accumulation;
* azimuthal angular-momentum eigenfunctions `exp(i m φ)`;
* the electric-dipole selection rule and a connector to graph theory.

The connector says that orbital parity is a graph homomorphism from the dipole
transition graph to the two-vertex graph: every transition changes parity, and
more generally every walk remembers the parity of its length.  Thus odd closed
walks are impossible.  This is the graph-theoretic content of the physical
parity selection rule.

This is a model of the spectral set, not a construction of the unbounded
Coulomb Schrödinger operator or a proof that its operator spectrum equals this
set; that deeper analytic development is left for future work.
-/

noncomputable section

open Set Filter Topology Complex

namespace HydrogenSpectralConnector

/-! ## Spectral set -/

/-- The positive principal quantum numbers. -/
abbrev PrincipalNumber := ℕ+

/-- Bound-state energy in Rydberg units. -/
def bohrEnergy (n : PrincipalNumber) : ℝ := -1 / (n : ℝ) ^ 2

/-- The idealized hydrogen spectral set: bound levels and scattering continuum. -/
def hydrogenSpectrum : Set ℝ :=
  {E | ∃ n : PrincipalNumber, E = bohrEnergy n} ∪ Ici 0

/-- Every bound level is below the ionization threshold. -/
theorem bohrEnergy_neg (n : PrincipalNumber) : bohrEnergy n < 0 := by
  exact div_neg_of_neg_of_pos (by norm_num) (by positivity)

/-- The ground-state energy is `-1`. -/
theorem bohrEnergy_ground : bohrEnergy 1 = -1 := by
  norm_num [bohrEnergy]

/-- The first four bound energies are `-1, -1/4, -1/9, -1/16`. -/
theorem first_four_bound_energies :
    bohrEnergy 1 = -1 ∧ bohrEnergy 2 = -(1 / 4 : ℝ) ∧
    bohrEnergy 3 = -(1 / 9 : ℝ) ∧ bohrEnergy 4 = -(1 / 16 : ℝ) := by
  norm_num [bohrEnergy]

/-- The Bohr levels strictly increase towards zero. -/
theorem bohrEnergy_strictMono : StrictMono bohrEnergy := by
  intro a b hab
  rw [bohrEnergy, bohrEnergy, div_lt_div_iff₀] <;> norm_num
  nlinarith [show (a : ℝ) < b from Nat.cast_lt.mpr hab,
    show (0 : ℝ) < a from Nat.cast_pos.mpr a.pos]

/-- A natural-number enumeration of bound energies tends to the threshold. -/
theorem bohrEnergy_tendsto_zero :
    Tendsto (fun n : ℕ => (-1 / ((n : ℝ) + 1) ^ 2)) atTop (𝓝 0) := by
  exact tendsto_const_nhds.div_atTop
    (Filter.tendsto_atTop_mono (fun n => by nlinarith) tendsto_natCast_atTop_atTop)

/-- Zero is an accumulation point of the discrete bound spectrum. -/
theorem zero_mem_closure_bound_levels :
    (0 : ℝ) ∈ closure {E | ∃ n : PrincipalNumber, E = bohrEnergy n} := by
  refine mem_closure_iff_seq_limit.mpr ?_
  refine ⟨fun n => bohrEnergy ⟨n + 1, Nat.succ_pos n⟩, ?_, ?_⟩
  · intro n
    exact ⟨⟨n + 1, Nat.succ_pos n⟩, rfl⟩
  · convert bohrEnergy_tendsto_zero using 1
    all_goals norm_num [bohrEnergy]

/-- The bound and scattering portions are disjoint. -/
theorem bound_scattering_disjoint :
    Disjoint {E | ∃ n : PrincipalNumber, E = bohrEnergy n} (Ici 0) := by
  refine Set.disjoint_left.mpr ?_
  rintro E ⟨n, rfl⟩ hnonneg
  exact (not_le_of_gt (bohrEnergy_neg n)) hnonneg

/-! ## Azimuthal angular momentum eigenfunctions -/

/-- The azimuthal factor `e^(imφ)` occurring in spherical harmonics. -/
def azimuthalMode (m : ℤ) (φ : ℝ) : ℂ :=
  Complex.exp ((m : ℂ) * φ * Complex.I)

/-- Azimuthal modes are single-valued under a full rotation. -/
theorem azimuthalMode_periodic (m : ℤ) (φ : ℝ) :
    azimuthalMode m (φ + 2 * Real.pi) = azimuthalMode m φ := by
  simp only [azimuthalMode]
  apply Complex.exp_eq_exp_iff_exists_int.mpr
  refine ⟨m, ?_⟩
  push_cast
  ring

/-- Derivative of an azimuthal mode. -/
theorem azimuthalMode_hasDerivAt (m : ℤ) (φ : ℝ) :
    HasDerivAt (azimuthalMode m)
      ((m : ℂ) * Complex.I * azimuthalMode m φ) φ := by
  unfold azimuthalMode
  have hg : HasDerivAt (fun x : ℝ => ((m : ℂ) * x) * Complex.I)
      ((m : ℂ) * Complex.I) φ := by
    simpa using ((hasDerivAt_id φ).ofReal_comp.const_mul (m : ℂ)).mul_const Complex.I
  have h := (Complex.hasDerivAt_exp (((m : ℂ) * φ) * Complex.I)).comp φ hg
  convert h using 1
  all_goals ring

/-- `e^(imφ)` is an eigenfunction of `Lz = -i ∂/∂φ`, with eigenvalue `m`. -/
theorem Lz_azimuthal_eigenvalue (m : ℤ) (φ : ℝ) :
    -Complex.I * deriv (azimuthalMode m) φ =
      (m : ℂ) * azimuthalMode m φ := by
  rw [(azimuthalMode_hasDerivAt m φ).deriv]
  ring_nf
  rw [Complex.I_sq]
  ring

/-! ## Dipole transitions and the graph-theoretic connector -/

/-- An orbital state, with orbital and magnetic quantum numbers. -/
structure OrbitalState where
  l : ℕ
  m : ℤ
  valid_m : |m| ≤ l

/-- Electric-dipole allowedness: `Δl = ±1` and `|Δm| ≤ 1`. -/
def DipoleAllowed (a b : OrbitalState) : Prop :=
  (b.l = a.l + 1 ∨ a.l = b.l + 1) ∧ |a.m - b.m| ≤ 1

/-- Dipole allowedness is symmetric, so it defines an undirected graph. -/
theorem dipoleAllowed_symm (a b : OrbitalState) :
    DipoleAllowed a b ↔ DipoleAllowed b a := by
  unfold DipoleAllowed
  rw [abs_sub_comm]
  constructor <;> rintro ⟨h, hm⟩ <;> exact ⟨h.symm, hm⟩

/-- The parity color of a state.  This is the two-coloring of the transition graph. -/
def parityColor (a : OrbitalState) : Fin 2 := ⟨a.l % 2, Nat.mod_lt _ (by omega)⟩

/-- **Quantum mechanics ↔ graph theory connector.** Every allowed dipole edge
crosses the orbital-parity bipartition. -/
theorem dipole_edge_crosses_parity (a b : OrbitalState)
    (h : DipoleAllowed a b) : parityColor a ≠ parityColor b := by
  intro heq
  have hv := congrArg Fin.val heq
  simp only [parityColor] at hv
  unfold DipoleAllowed at h
  omega

/-- A walk in the dipole transition graph, indexed by its number of edges. -/
inductive DipoleWalk : ℕ → OrbitalState → OrbitalState → Prop
  | nil (a) : DipoleWalk 0 a a
  | cons {k a b c} : DipoleAllowed a b → DipoleWalk k b c → DipoleWalk (k + 1) a c

/-- Along a dipole walk, endpoint orbital quantum numbers differ in parity
exactly when the walk length is odd. -/
theorem dipole_walk_parity {k : ℕ} {a b : OrbitalState}
    (w : DipoleWalk k a b) : (a.l + b.l) % 2 = k % 2 := by
  induction w with
  | nil a => omega
  | @cons k a b c hab hbc ih =>
      unfold DipoleAllowed at hab
      rcases hab.1 with h | h <;> omega

/-- An odd-length closed dipole walk cannot exist.  Equivalently, the dipole
transition graph has no odd cycle. -/
theorem no_odd_closed_dipole_walk {k : ℕ} {a : OrbitalState}
    (hk : Odd k) : ¬ DipoleWalk k a a := by
  intro w
  have hp := dipole_walk_parity w
  obtain ⟨r, rfl⟩ := hk
  omega

/-- Two successive dipole transitions return to the original parity class. -/
theorem two_step_preserves_parity {a b c : OrbitalState}
    (hab : DipoleAllowed a b) (hbc : DipoleAllowed b c) :
    parityColor a = parityColor c := by
  have w : DipoleWalk 2 a c := by
    simpa using DipoleWalk.cons hab (DipoleWalk.cons hbc (DipoleWalk.nil c))
  have hp := dipole_walk_parity w
  apply Fin.ext
  simp only [parityColor]
  omega

end HydrogenSpectralConnector