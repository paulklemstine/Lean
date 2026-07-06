import Mathlib
import Computation.Demushkin.CupForm

/-!
# The isotropy locus of a pro-2 Demushkin cup-product form

Building on `Computation.Demushkin.CupForm`, this file studies the set of **isotropic**
cohomology classes of a pro-2 Demushkin group, i.e. classes `x ∈ H¹(G;𝔽₂)` with
`x ∪ x = 0`.

Over a field of characteristic `≠ 2` the isotropic vectors of a nondegenerate symmetric
form are a quadric hypersurface — emphatically *not* a linear subspace.  The main point of
this file is the **characteristic-two surprise**: because the squaring map `x ↦ x ∪ x` is
`𝔽₂`-*linear* (`DemushkinCupForm.sqForm`), the isotropic classes form a **linear
subspace** `isotropic`, and moreover this subspace is exactly the hyperplane orthogonal to
the Kummer class.

* `DemushkinCupForm.isotropic` — the isotropic classes packaged as a `Submodule`.
* `DemushkinCupForm.isotropic_eq_kummer_perp` — `x` is isotropic **iff** `χ ∪ x = 0`;
  the isotropy locus is the orthogonal hyperplane of the Kummer class `χ`.
* `DemushkinCupForm.isotropic_eq_top_iff_alt` — the isotropy locus is everything iff the
  form is alternating (the "even type").
* `DemushkinCupForm.isotropy_codim_one` — for a Demushkin form of *odd type* the isotropic
  classes form a hyperplane: `dim(isotropic) + 1 = dim H¹`.  Exactly half of the classes
  are isotropic.
* `DemushkinCupForm.card_isotropic_odd_type` — the counting corollary
  `|isotropic| = 2 ^ (dim H¹ - 1)`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Over `𝔽₂` the isotropy locus `{x : x∪x = 0}` of the Demushkin
cup product is not a quadric but a *linear subspace*, and its codimension is a binary
invariant: `0` (even type) or `1` (odd type).  Surprising because in every other
characteristic the isotropy locus is a genuine quadric.

Experiment (Experimenter): `x∪x = sqForm x` and `sqForm` is linear, so the isotropy locus
is `ker sqForm`, automatically a subspace.  For the codimension, `sqForm` is a functional
into the `1`-dimensional space `𝔽₂`: it is either `0` (even type, kernel everything) or
surjective (odd type, kernel a hyperplane).  Rank–nullity finishes it, and
`Module.card_eq_pow_finrank` turns the dimension count into a cardinality count.

Analysis (Analyst): The dichotomy `codim ∈ {0,1}` is precisely the Demushkin type
invariant re-expressed geometrically.  Via `kummer_spec` the locus is the orthogonal
complement of the Kummer class `χ`, tying the geometric picture back to the canonical
class of `CupForm.lean`.

Critique (Critic): The subspace structure crucially uses characteristic two (linearity of
squaring); over `ℝ` the analogous statement is false.  The codimension theorem genuinely
uses nondegeneracy only through the hypothesis `¬ IsAlt` producing a nonzero functional;
rank–nullity (`LinearMap.finrank_range_add_finrank_ker`) does the real work, so the result
is not a `decide`/`simp` triviality.
-/

open LinearMap (BilinForm)

namespace DemushkinCupForm

variable {V : Type*} [AddCommGroup V] [Module (ZMod 2) V]

/-- The **isotropy locus** of a symmetric cup-product form over `𝔽₂`: the classes `x` with
`x ∪ x = 0`.  A genuine `Submodule` — this is a characteristic-two phenomenon, since it is
the kernel of the *linear* squaring functional `sqForm`. -/
def isotropic (B : BilinForm (ZMod 2) V) (hsymm : B.IsSymm) : Submodule (ZMod 2) V :=
  LinearMap.ker (sqForm B hsymm)

@[simp] theorem mem_isotropic_iff (B : BilinForm (ZMod 2) V) (hsymm : B.IsSymm) (x : V) :
    x ∈ isotropic B hsymm ↔ B x x = 0 := by
  simp [isotropic, LinearMap.mem_ker]

/-- The form is **alternating** (even type) iff the isotropy locus is the whole space. -/
theorem isotropic_eq_top_iff_alt (B : BilinForm (ZMod 2) V) (hsymm : B.IsSymm) :
    isotropic B hsymm = ⊤ ↔ ∀ x, B x x = 0 := by
  constructor
  · intro h x
    have : x ∈ isotropic B hsymm := by rw [h]; exact Submodule.mem_top
    exact (mem_isotropic_iff B hsymm x).mp this
  · intro h
    ext x
    simp [mem_isotropic_iff, h x]

variable [FiniteDimensional (ZMod 2) V]

/-- The isotropy locus is the **orthogonal hyperplane of the Kummer class**: `x∪x = 0` iff
`χ ∪ x = 0`. -/
theorem isotropic_eq_kummer_perp (B : BilinForm (ZMod 2) V) (hsymm : B.IsSymm)
    (hB : B.Nondegenerate) (x : V) :
    x ∈ isotropic B hsymm ↔ B (kummer B hsymm hB) x = 0 := by
  rw [mem_isotropic_iff, kummer_spec]

/-- **Odd-type Demushkin dichotomy (dimension form).** If the cup-product form is *not*
alternating, its isotropy locus is a hyperplane: the isotropic classes have codimension
exactly one. -/
theorem isotropy_codim_one (B : BilinForm (ZMod 2) V) (hsymm : B.IsSymm)
    (hnotalt : ¬ ∀ x, B x x = 0) :
    Module.finrank (ZMod 2) (isotropic B hsymm) + 1 = Module.finrank (ZMod 2) V := by
  have hf : sqForm B hsymm ≠ 0 := by
    intro h
    apply hnotalt
    intro x
    have : sqForm B hsymm x = 0 := by rw [h]; rfl
    simpa using this
  have hrng : LinearMap.range (sqForm B hsymm) ≠ ⊥ := by
    rw [Ne, LinearMap.range_eq_bot]; exact hf
  have hle : Module.finrank (ZMod 2) (LinearMap.range (sqForm B hsymm)) ≤ 1 := by
    simpa using Submodule.finrank_le (LinearMap.range (sqForm B hsymm))
  have hne : Module.finrank (ZMod 2) (LinearMap.range (sqForm B hsymm)) ≠ 0 := by
    rw [Ne, Submodule.finrank_eq_zero]; exact hrng
  have hrn := LinearMap.finrank_range_add_finrank_ker (sqForm B hsymm)
  simp only [isotropic]
  omega

/-- **Counting corollary.** For a finite Demushkin cohomology group `H¹` of odd type,
exactly half the classes are isotropic: `|{x : x∪x = 0}| = 2 ^ (dim H¹ - 1)`. -/
theorem card_isotropic_odd_type [Fintype V] (B : BilinForm (ZMod 2) V) (hsymm : B.IsSymm)
    (hnotalt : ¬ ∀ x, B x x = 0) :
    Nat.card (isotropic B hsymm) = 2 ^ (Module.finrank (ZMod 2) V - 1) := by
  classical
  have hcodim := isotropy_codim_one B hsymm hnotalt
  have hfin : Fintype (isotropic B hsymm) := Fintype.ofFinite _
  have hcard : Fintype.card (isotropic B hsymm)
      = 2 ^ Module.finrank (ZMod 2) (isotropic B hsymm) := by
    have := @Module.card_eq_pow_finrank (ZMod 2) (isotropic B hsymm) _ _ _ _ hfin
    simpa using this
  rw [Nat.card_eq_fintype_card, hcard]
  congr 1
  omega

end DemushkinCupForm