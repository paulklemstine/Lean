import Mathlib
import Geometry.RhoDominantCartan
/-!
# Orbit-basis decomposition for Weyl-invariant functions

The decomposition theorem for twisted Weyl group multiple Dirichlet series separates two
ideas: dominant weights index disjoint Weyl orbits, while shifted Chinta--Gunnells averages
supply invariant functions supported on those orbits.  This file isolates the finite-orbit
algebraic mechanism.  Given a finite family of representatives whose orbits partition a
`G`-set, every invariant function has a unique expansion in the corresponding normalized
orbit indicators.  A Reynolds average supplies the companion projection from arbitrary
functions to invariant functions.

This is an algebraic finite-model counterpart of the paper's analytic decomposition.  The
analytic continuation and convergence hypotheses needed for infinite Kac--Moody Weyl groups
are deliberately not asserted here.

The import of `RhoDominantCartan` links the abstract representative set to the catalog's
simply-laced dominance criterion: in applications, its `IsRhoDominant` predicate provides a
finite combinatorial test for candidate dominant labels.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): Once dominant labels select exactly one point from every relevant
Weyl orbit, uniqueness of the shifted-average expansion is an orbit-partition theorem, rather
than an analytic accident.  More boldly, Reynolds projection and orbit-basis reconstruction
should be two faces of one finite-group mechanism, valid over every field whose characteristic
does not divide the group order.
EXPERIMENT (Experimenter): Replaced the unavailable infinite Kac--Moody analytic apparatus by
a finite group action.  Normalized orbit indicators were tested on the regular action, where
there is one orbit and invariance is exactly constancy.  The coefficient at an orbit is forced
by evaluation at its representative.
ANALYSIS (Analyst): Three structural ingredients suffice: orbit membership is unchanged by the
group action; unique orbit coverage collapses a finite sum to one term; and reindexing a group
sum proves invariance of Reynolds averaging.  Thus support decomposition (combinatorics) and
averaging (representation theory) meet without analytic assumptions.
CRITIQUE (Critic): This does not formalize the twisted cocycle, convergence, meromorphic
continuation, or the affine extra functional equations.  The boundary is genuine: for an
infinite Weyl group, the Reynolds sum is unavailable and orbit indicators need not satisfy the
paper's analytic hypotheses.  If representatives overlap, uniqueness fails; if the group order
vanishes in the field, normalized averaging fails.  None of the main results is definitional,
and the proofs use orbit transport, unique existence, finite-sum elimination, and extensionality.
SYNTHESIS (Principal Investigator): The verified core is a reusable orbit-basis theorem plus a
finite Reynolds projection.  `RhoDom.dominant_univ_iff` can supply graph-theoretic dominant
labels, while future work must replace finite indicators by convergent shifted
Chinta--Gunnells averages on the complexified Tits cone.
-- !-- end Lab Notes -- !--
-/

namespace WeylDirichlet

open MulAction Finset Classical

section OrbitBasis

variable {G X ι R : Type*} [Group G] [MulAction G X] [Semiring R]

/-- The normalized invariant attached to the orbit of a representative. -/
noncomputable def orbitIndicator (G : Type*) [Group G] [MulAction G X]
    (rep : ι → X) (i : ι) (x : X) : R :=
  if x ∈ MulAction.orbit G (rep i) then 1 else 0

/-- Orbit indicators are invariant under the group action. -/
theorem orbitIndicator_smul (rep : ι → X) (i : ι) (g : G) (x : X) :
    (orbitIndicator G rep i (g • x) : R) = orbitIndicator G rep i x := by
  unfold orbitIndicator
  congr 1
  rw [MulAction.mem_orbit_iff, MulAction.mem_orbit_iff]
  apply propext
  constructor
  · rintro ⟨h, hh⟩
    refine ⟨g⁻¹ * h, ?_⟩
    rw [mul_smul, hh, inv_smul_smul]
  · rintro ⟨h, hh⟩
    refine ⟨g * h, ?_⟩
    rw [mul_smul, hh]

/-- At chosen representatives, orbit indicators form the Kronecker delta. -/
theorem orbitIndicator_rep (rep : ι → X)
    (hunique : ∀ x, ∃! i, x ∈ MulAction.orbit G (rep i)) (i j : ι) :
    (orbitIndicator G rep i (rep j) : R) = if i = j then 1 else 0 := by
  unfold orbitIndicator
  by_cases hij : i = j
  · subst i
    have hj : rep j ∈ MulAction.orbit G (rep j) := by
      rw [MulAction.mem_orbit_iff]
      exact ⟨1, one_smul G (rep j)⟩
    rw [if_pos hj, if_pos rfl]
  · simp only [if_neg hij]
    rw [if_neg]
    intro hi
    have hj : rep j ∈ MulAction.orbit G (rep j) := by
      rw [MulAction.mem_orbit_iff]
      exact ⟨1, one_smul G (rep j)⟩
    rcases hunique (rep j) with ⟨k, hk, huniq⟩
    exact hij ((huniq i hi).trans (huniq j hj).symm)

/-- **Finite orbit-basis decomposition.** An invariant function is reconstructed from its
values on a unique set of orbit representatives. -/
theorem invariant_decomposition [Fintype ι] (rep : ι → X)
    (hunique : ∀ x, ∃! i, x ∈ MulAction.orbit G (rep i))
    (f : X → R) (hinv : ∀ (g : G) (x : X), f (g • x) = f x) (x : X) :
    f x = ∑ i, f (rep i) * orbitIndicator G rep i x := by
  rcases hunique x with ⟨j, hj, huniq⟩
  have hvalue : f x = f (rep j) := by
    rw [MulAction.mem_orbit_iff] at hj
    rcases hj with ⟨g, rfl⟩
    exact hinv g (rep j)
  rw [hvalue]
  symm
  rw [Fintype.sum_eq_single j]
  · simp [orbitIndicator, hj]
  · intro i hij
    have hnot : x ∉ MulAction.orbit G (rep i) := by
      intro hiOrbit
      exact hij (huniq i hiOrbit)
    simp [orbitIndicator, hnot]

/-- The coefficients of an orbit-indicator expansion are unique. -/
theorem orbit_expansion_unique [Fintype ι] (rep : ι → X)
    (hunique : ∀ x, ∃! i, x ∈ MulAction.orbit G (rep i))
    (f : X → R) (c : ι → R)
    (hexp : ∀ x, f x = ∑ i, c i * orbitIndicator G rep i x) :
    c = fun i => f (rep i) := by
  funext j
  have hj := hexp (rep j)
  rw [Fintype.sum_eq_single j] at hj
  · simpa [orbitIndicator_rep (G := G) (R := R) rep hunique j j] using hj.symm
  · intro i hij
    rw [orbitIndicator_rep (G := G) (R := R) rep hunique i j, if_neg hij]
    simp

/-- Existence and uniqueness packaged as a single decomposition statement. -/
theorem existsUnique_orbit_expansion [Fintype ι] (rep : ι → X)
    (hunique : ∀ x, ∃! i, x ∈ MulAction.orbit G (rep i))
    (f : X → R) (hinv : ∀ (g : G) (x : X), f (g • x) = f x) :
    ∃! c : ι → R, ∀ x, f x = ∑ i, c i * orbitIndicator G rep i x := by
  refine ⟨fun i => f (rep i), ?_, ?_⟩
  · exact invariant_decomposition (G := G) rep hunique f hinv
  · intro c hc
    exact orbit_expansion_unique (G := G) rep hunique f c hc

end OrbitBasis

section Reynolds

variable {G X F : Type*} [Group G] [Fintype G] [MulAction G X] [Field F]

/-- Reynolds averaging of a function on a finite `G`-set. -/
noncomputable def reynolds (f : X → F) (x : X) : F :=
  (Fintype.card G : F)⁻¹ * ∑ g : G, f (g • x)

/-- Reynolds averaging produces an invariant function. -/
theorem reynolds_invariant (f : X → F) (h : G) (x : X) :
    reynolds (G := G) f (h • x) = reynolds (G := G) f x := by
  unfold reynolds
  congr 1
  calc
    ∑ g : G, f (g • h • x) = ∑ g : G, f ((g * h) • x) := by
      apply Finset.sum_congr rfl
      intro g hg
      rw [mul_smul]
    _ = ∑ g : G, f (g • x) := Equiv.sum_comp (Equiv.mulRight h) (fun g : G => f (g • x))

/-- Averaging fixes invariant functions whenever the group order is nonzero in the field. -/
theorem reynolds_eq_self (f : X → F) (hinv : ∀ (g : G) (x : X), f (g • x) = f x)
    (hcard : (Fintype.card G : F) ≠ 0) :
    reynolds (G := G) f = f := by
  funext x
  unfold reynolds
  simp_rw [hinv]
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  rw [← mul_assoc, inv_mul_cancel₀ hcard, one_mul]

/-- Under the same characteristic hypothesis, Reynolds averaging is idempotent. -/
theorem reynolds_idempotent (f : X → F) (hcard : (Fintype.card G : F) ≠ 0) :
    reynolds (G := G) (reynolds (G := G) f) = reynolds (G := G) f := by
  apply reynolds_eq_self (G := G)
  · exact reynolds_invariant (G := G) f
  · exact hcard

end Reynolds

section Examples

/-- For the regular action of a finite group on itself there is one orbit, so every invariant
function is constant and its orbit expansion has one coefficient. -/
example {G F : Type*} [Group G] [Fintype G] [Field F] (f : G → F)
    (hinv : ∀ g x : G, f (g * x) = f x) (x : G) : f x = f 1 := by
  simpa using hinv x 1

#check RhoDom.dominant_univ_iff
#check invariant_decomposition
#check reynolds_idempotent

end Examples

end WeylDirichlet