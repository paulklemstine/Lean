import Physics.StabilizerBounds

/-!
# Singleton Bounds and Geometric Parameter Dictionaries

This study tests a proposed identification between geometric length scales and the
parameters of a quantum stabilizer code.  Its central distinction is between an
inequality and its saturation: the quantum Singleton bound imposes
`2d + k ≤ n + 2`; it does not by itself identify `k` with `n - 2d + 2`.

The length dictionary `n = 2d`, suggested by measuring a boundary length in Planck
units while taking distance to be half that length, is especially rigid.  It leaves
room for at most two logical qubits.  Thus an entropy identified with `k` cannot grow
with boundary size under this dictionary unless at least one proposed identification
is changed.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (H1) Singleton saturation, rather than Singleton validity,
produces the exact identity `k = n - 2d + 2`.  (H2) A geometric dictionary `n = 2d`
forces bounded logical entropy.  (H3) Reversing the redundancy inequality and imposing
the genuine Singleton inequality simultaneously forces a sharply determined parameter.
Bold extensions tested were a quantitative defect law, an asymptotic vanishing-rate
result, and an incompatibility theorem for extensive entropy.

Experiment (Experimenter): The existing stabilizer-code parameter framework was used
as the coding-theoretic anchor.  Natural-number subtraction was avoided in the main
arguments by retaining the subtraction-free inequality `2d + k ≤ n + 2`.  A geometric
defect `delta`, defined by `n = 2d + delta`, was introduced and propagated through the
bound.

Analysis (Analyst): H1 survives only with an explicit saturation hypothesis.  H2
survives and strengthens to `k ≤ delta + 2`.  H3 survives: at exact balance, the
incorrectly reversed redundancy inequality says `2 ≤ k`, whereas Singleton says
`k ≤ 2`; together they force `k = 2`.  The common structural pattern is that the
excess `n - 2d`, not area alone, controls logical capacity.

Critique (Critic): These conclusions concern parameter arithmetic, not the existence
or dynamics of a spacetime code.  No claim is made that a stabilizer code realizes a
geometry, that geodesic length is code distance, or that matter is a syndrome.  The
factor-of-two dictionary is an assumption and is exposed in every theorem that uses
it.  Corner cases at distance zero are excluded where subtraction equivalences need
`1 ≤ d`.

Synthesis (Principal Investigator): The surviving theorem is a defect-capacity law:
for a Singleton-valid code with `n = 2d + delta`, one has `k ≤ delta + 2`.  Exact
balance gives constant capacity, while extensive logical entropy requires an
extensive geometric defect.
-- !--
-/

namespace GravityQECC

open QuantumStabilizer

/-- The excess of physical size over twice the distance, expressed without truncated
subtraction by a witness equation. -/
def HasGeometricDefect (p : CodeParams) (delta : ℕ) : Prop :=
  p.n = 2 * p.d + delta

/--
The Singleton inequality is equivalent to the usual redundancy form when the
basic parameter bounds make natural-number subtraction exact.
-/
theorem singleton_iff_redundancy (p : CodeParams) (hk : p.k ≤ p.n) (hd : 1 ≤ p.d) :
    2 * p.d + p.k ≤ p.n + 2 ↔ 2 * (p.d - 1) ≤ p.n - p.k := by
  omega

/--
Singleton saturation, not merely the Singleton bound, yields the proposed exact
logical-capacity identity.
-/
theorem saturation_capacity_identity (p : CodeParams)
    (hsat : 2 * p.d + p.k = p.n + 2) :
    p.k + 2 * p.d = p.n + 2 := by
  simpa [add_comm] using hsat

/--
Quantitative defect-capacity law: every extra physical unit beyond `2d` can add at
most one logical unit, apart from the universal additive constant two.
-/
theorem logical_capacity_le_defect (p : CodeParams) (h : SingletonValidCode p)
    (delta : ℕ) (hgeom : HasGeometricDefect p delta) :
    p.k ≤ delta + 2 := by
  have hs := h.singleton
  unfold HasGeometricDefect at hgeom
  omega

/--
Exact geometric balance `n = 2d` permits at most two logical qubits.
-/
theorem balanced_geometry_capacity_at_most_two (p : CodeParams)
    (h : SingletonValidCode p) (hgeom : p.n = 2 * p.d) :
    p.k ≤ 2 := by
  apply logical_capacity_le_defect p h 0
  simpa [HasGeometricDefect] using hgeom

/--
A balanced geometric dictionary is incompatible with three or more logical
qubits, independently of the overall scale.
-/
theorem no_balanced_extensive_entropy (p : CodeParams)
    (hgeom : p.n = 2 * p.d) (hk3 : 3 ≤ p.k) :
    ¬ SingletonValidCode p := by
  intro h
  have hk2 := balanced_geometry_capacity_at_most_two p h hgeom
  omega

/--
At exact balance, saturation occurs precisely at logical capacity two.
-/
theorem balanced_saturation_iff (p : CodeParams) (hgeom : p.n = 2 * p.d) :
    2 * p.d + p.k = p.n + 2 ↔ p.k = 2 := by
  constructor <;> intro h <;> omega

/--
Under exact balance and valid parameter ordering, the reversed inequality proposed
in the motivating calculation is equivalent to the lower bound `2 ≤ k`.
-/
theorem reversed_redundancy_at_balance (p : CodeParams) (hk : p.k ≤ p.n)
    (hd : 1 ≤ p.d) (hgeom : p.n = 2 * p.d) :
    p.n - p.k ≤ 2 * (p.d - 1) ↔ 2 ≤ p.k := by
  constructor <;> intro <;> omega

/--
Combining the genuine Singleton inequality with its proposed reversal collapses
balanced parameters to the single value `k = 2`.
-/
theorem direction_collision_forces_two (p : CodeParams) (h : SingletonValidCode p)
    (hgeom : p.n = 2 * p.d) (hreversed : p.n - p.k ≤ 2 * (p.d - 1)) :
    p.k = 2 := by
  have hk_upper := balanced_geometry_capacity_at_most_two p h hgeom
  have hk_lower := (reversed_redundancy_at_balance p h.hk h.hd hgeom).mp hreversed
  exact Nat.le_antisymm hk_upper hk_lower

/--
Extensive entropy requires extensive defect: if `m` logical qubits are demanded,
then the defect must be at least `m - 2`.
-/
theorem entropy_demand_forces_defect (p : CodeParams) (h : SingletonValidCode p)
    (delta m : ℕ) (hgeom : HasGeometricDefect p delta) (hdemand : m ≤ p.k) :
    m ≤ delta + 2 := by
  exact hdemand.trans (logical_capacity_le_defect p h delta hgeom)

/--
In a family whose geometric defect is uniformly bounded by `D`, every member has
logical capacity at most `D + 2`; growth of `n` alone cannot produce growing `k`.
-/
theorem bounded_defect_family_bounded_capacity
    (p : ℕ → CodeParams) (delta : ℕ → ℕ) (D : ℕ)
    (hsingleton : ∀ i, SingletonValidCode (p i))
    (hgeom : ∀ i, HasGeometricDefect (p i) (delta i))
    (hbound : ∀ i, delta i ≤ D) :
    ∀ i, (p i).k ≤ D + 2 := by
  intro i
  have hk := logical_capacity_le_defect (p i) (hsingleton i) (delta i) (hgeom i)
  have hd := hbound i
  omega

/-- Uniformly bounded geometric defect forces the logical rate `k/n` to become
arbitrarily small once the physical size is sufficiently large. -/
theorem bounded_defect_rate_eventually_small
    (p : ℕ → CodeParams) (delta : ℕ → ℕ) (D : ℕ)
    (hsingleton : ∀ i, SingletonValidCode (p i))
    (hgeom : ∀ i, HasGeometricDefect (p i) (delta i))
    (hbound : ∀ i, delta i ≤ D) (epsilon : ℝ) (hepsilon : 0 < epsilon) :
    ∃ N : ℕ, ∀ i, N ≤ (p i).n → ((p i).k : ℝ) / (p i).n < epsilon := by
  use ⌈epsilon⁻¹ * (D + 2)⌉₊ + 1
  intro i hi
  rw [div_lt_iff₀] <;>
    nlinarith [Nat.le_ceil (epsilon⁻¹ * (D + 2)),
      mul_inv_cancel₀ (ne_of_gt hepsilon),
      show ((p i).n : ℝ) ≥ ⌈epsilon⁻¹ * (D + 2)⌉₊ + 1 by exact_mod_cast hi,
      show ((p i).k : ℝ) ≤ D + 2 by
        exact_mod_cast bounded_defect_family_bounded_capacity
          p delta D hsingleton hgeom hbound i]

end GravityQECC