import Mathlib

/-!
# The cup-product form of a pro-2 Demushkin group

For a pro-`p` **Demushkin group** `G` the mod-`p` cohomology is concentrated in degrees
`0, 1, 2` with `H⁰ ≅ 𝔽ₚ`, `H² ≅ 𝔽ₚ`, and the **cup product**
`H¹(G;𝔽ₚ) × H¹(G;𝔽ₚ) → H²(G;𝔽ₚ) ≅ 𝔽ₚ`
a *nondegenerate symmetric bilinear form*.  This nondegeneracy is the defining feature
of a Demushkin group (it expresses Poincaré duality of the group).

This file models the cup-product form of a **pro-2** Demushkin group: `H¹` is a
finite-dimensional `𝔽₂ = ZMod 2` vector space `V`, and the cup product is a nondegenerate
symmetric bilinear form `B : V × V → 𝔽₂`.  We isolate the characteristic-two phenomena
that control the *A₃-formality* / Benson–Krause–Schwede canonical class of `C^*(G;𝔽₂)`:

* `DemushkinCupForm.sqForm` — the **self-cup / squaring** map `x ↦ x ∪ x` is
  `𝔽₂`-*linear* (a genuinely characteristic-two phenomenon: the cross term `2·(x∪y)`
  vanishes).  Packaged as a linear functional `V →ₗ[𝔽₂] 𝔽₂`.
* `DemushkinCupForm.kummer` and `DemushkinCupForm.kummer_spec` — because the cup product
  is a perfect pairing, the squaring functional is represented by a **unique** class
  `χ ∈ H¹` with `x ∪ x = χ ∪ x` for all `x`.  This is the canonical *Kummer / orientation
  class* of the Demushkin group.
* `DemushkinCupForm.alternating_iff_kummer_zero` — the form is *alternating*
  (`x ∪ x = 0` for all `x`, the "even / orientable type") **iff** `χ = 0`.  This is the
  Demushkin type dichotomy expressed through the canonical class.
* `DemushkinCupForm.exists_cup_one` — nondegeneracy in its usable form: every nonzero
  class is detected by the cup product.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The obstruction to `A₃`-formality of `C^*(G;𝔽₂)` is a
characteristic-two secondary operation built from the cup product.  Since `H^{≥3} = 0` for
a Demushkin group, the only room for a nontrivial canonical class is a degree `-1` ternary
operation `H¹⊗H¹⊗H¹ → H²`, and this is governed by the linear-algebraic structure of the
cup-product form.  Conjecture: over `𝔽₂` the squaring `x ↦ x∪x` is *linear*, and this
linearity is exactly what trivialises the secondary operation.

Experiment (Experimenter): Compute `(x+y)∪(x+y) = x∪x + 2(x∪y) + y∪y`.  In characteristic
two `2(x∪y)=0`, so squaring is additive; and `(c·x)∪(c·x)=c²(x∪x)=c(x∪x)` because
`c² = c` on `𝔽₂`.  Hence squaring is a genuine linear functional `q : V →ₗ[𝔽₂] 𝔽₂`.
Nondegeneracy (`BilinForm.toDual`) then represents `q` by a unique class `χ`.

Analysis (Analyst): The Kummer class `χ` is the linear-algebra shadow of the
Benson–Krause–Schwede canonical class.  Its vanishing detects the "even type" (alternating
form).  The construction uses *only* symmetry (for linearity of `q`) and nondegeneracy
(for representability), matching precisely the two Demushkin axioms.

Critique (Critic): None of the results are vacuous or definitional: linearity of squaring
genuinely uses `2 = 0` and `c² = c` in `𝔽₂`; the Kummer class uses the perfect pairing
`V ≃ₗ V*`; the dichotomy combines both.  The nondegeneracy hypothesis is load-bearing in
`kummer_unique`, `exists_cup_one`, and the backward direction of the dichotomy.
-/

open LinearMap (BilinForm)

namespace DemushkinCupForm

variable {V : Type*} [AddCommGroup V] [Module (ZMod 2) V]

/-- The **squaring / self-cup functional** `x ↦ B x x` of a symmetric bilinear form over
`𝔽₂`.  In characteristic two this is `𝔽₂`-linear, so it is a genuine element of the dual
space.  (This is the linear-algebra avatar of the fact that, mod 2, `x ∪ x` is a linear
function of `x`.) -/
def sqForm (B : BilinForm (ZMod 2) V) (hsymm : B.IsSymm) : V →ₗ[ZMod 2] ZMod 2 where
  toFun x := B x x
  map_add' x y := by
    have h : B y x = B x y := by have := hsymm.eq x y; simpa using this.symm
    have hc : ((B x) y) + ((B x) y) = (0 : ZMod 2) := CharTwo.add_self_eq_zero _
    simp only [map_add, LinearMap.add_apply, h]
    linear_combination hc
  map_smul' c x := by
    simp only [map_smul, LinearMap.smul_apply, smul_eq_mul, RingHom.id_apply]
    have hcc : c * c = c := by revert c; decide
    rw [← mul_assoc, hcc]

@[simp] theorem sqForm_apply (B : BilinForm (ZMod 2) V) (hsymm : B.IsSymm) (x : V) :
    sqForm B hsymm x = B x x := rfl

/-- **Nondegeneracy, detected form.** Every nonzero cohomology class pairs nontrivially:
there is a class `x` with `a ∪ x = 1`. -/
theorem exists_cup_one (B : BilinForm (ZMod 2) V) (hB : B.Nondegenerate)
    {a : V} (ha : a ≠ 0) : ∃ x, B a x = 1 := by
  contrapose! ha
  refine hB.1 a fun x => ?_
  have hx := ha x
  have : ∀ v : ZMod 2, v ≠ 1 → v = 0 := by decide
  exact this _ hx

variable [FiniteDimensional (ZMod 2) V]

/-- The **Kummer / orientation class** of a Demushkin cup-product form: the unique class
representing the squaring functional under the perfect pairing.  Concretely it is
characterised by `x ∪ x = χ ∪ x` for all `x` (see `kummer_spec`). -/
noncomputable def kummer (B : BilinForm (ZMod 2) V) (hsymm : B.IsSymm)
    (hB : B.Nondegenerate) : V :=
  (B.toDual hB).symm (sqForm B hsymm)

/-- Defining property of the Kummer class: `B χ x = B x x` for every `x`, i.e.
`χ ∪ x = x ∪ x`. -/
theorem kummer_spec (B : BilinForm (ZMod 2) V) (hsymm : B.IsSymm) (hB : B.Nondegenerate)
    (x : V) : B (kummer B hsymm hB) x = B x x := by
  have h1 : (B.toDual hB) (kummer B hsymm hB) = sqForm B hsymm := by
    rw [kummer]; exact LinearEquiv.apply_symm_apply _ _
  have h2 : (B.toDual hB (kummer B hsymm hB)) x = B (kummer B hsymm hB) x := by
    simp [LinearMap.BilinForm.toDual]
  rw [← h2, h1]; rfl

/-- The Kummer class is the *unique* class with the defining property. -/
theorem kummer_unique (B : BilinForm (ZMod 2) V) (hsymm : B.IsSymm) (hB : B.Nondegenerate)
    (w : V) (hw : ∀ x, B w x = B x x) : w = kummer B hsymm hB := by
  have hd : ∀ x, B (w - kummer B hsymm hB) x = 0 := by
    intro x; rw [map_sub, LinearMap.sub_apply, hw x, kummer_spec]; ring
  exact sub_eq_zero.mp (hB.1 (w - kummer B hsymm hB) hd)

/-- **Demushkin type dichotomy.** The cup-product form is *alternating* (`x ∪ x = 0` for
all `x`, the even / orientable type) if and only if the Kummer class vanishes. -/
theorem alternating_iff_kummer_zero (B : BilinForm (ZMod 2) V) (hsymm : B.IsSymm)
    (hB : B.Nondegenerate) :
    (∀ x, B x x = 0) ↔ kummer B hsymm hB = 0 := by
  constructor
  · intro h
    have hz : sqForm B hsymm = 0 := by ext x; simp [h x]
    rw [kummer, hz, map_zero]
  · intro h x
    have hx := kummer_spec B hsymm hB x
    rw [h] at hx; simpa using hx.symm

end DemushkinCupForm