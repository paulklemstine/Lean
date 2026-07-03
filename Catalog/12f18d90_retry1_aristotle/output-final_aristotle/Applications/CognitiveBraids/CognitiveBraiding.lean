/-
  # Cognitive Braids: Writhe as an Information Invariant

  Building on `Catalog/Cryptography/BraidGroup.lean`, we model three
  "cognitive braids" and study the writhe (exponent sum) homomorphism as an
  information invariant.

  * `creativeBraid  := σ₀³            : BraidGrp 1`  — a "creative" braid,
    a pure repetition of one generator.
  * `confusedBraid  := (σ₀ σ₁⁻¹)²     : BraidGrp 2`  — a "confused" braid,
    balanced positive/negative crossings.
  * `trivialBraid   := 1              : BraidGrp 1`  — the trivial braid.

  We prove:
  * `writhe creativeBraid = 3` (writhe detects the creative repetition),
  * `writhe trivialBraid  = 0`,
  * `writhe confusedBraid = 0` (writhe is *blind* to the confused braid: its
    balanced crossings cancel in the exponent sum),

  and then that `confusedBraid` is nonetheless a nontrivial braid, because its
  image under the symmetric-group quotient `toSymm` is not the identity
  permutation.  Thus the writhe cannot distinguish `confusedBraid` from the
  trivial braid, even though they are distinct braids: writhe detects
  "creativity" (a nonzero exponent sum) but is blind to "confusion"
  (nontriviality with vanishing exponent sum).

  Note on typing.  In the informal statement `confusedBraid` lives in
  `BraidGrp 2` (it uses the generator `σ₁`), whereas `trivialBraid` lives in
  `BraidGrp 1`; these are different groups, so `confusedBraid ≠ trivialBraid`
  cannot be stated literally.  The faithful statement is that `confusedBraid`
  differs from the trivial braid *of its own group*, i.e.
  `confusedBraid ≠ (1 : BraidGrp 2)`; this is `confusedBraid_ne_trivial` below.

  The values of `writhe` land in `Multiplicative ℤ`, so the integer `k` is
  written `Multiplicative.ofAdd (k : ℤ)`, and `0` is the group identity `1`.
-/
import Mathlib
import Catalog.Cryptography.BraidGroup

namespace BraidGroup
namespace CognitiveBraids

/-! ## The three cognitive braids -/

/-- The "creative" braid `σ₀³ ∈ B₂ = BraidGrp 1`: a pure repetition of a single
    positive generator. -/
def creativeBraid : BraidGrp 1 := sigma (0 : Fin 1) ^ 3

/-- The "confused" braid `(σ₀ σ₁⁻¹)² ∈ B₃ = BraidGrp 2`: balanced positive and
    negative crossings. -/
def confusedBraid : BraidGrp 2 := (sigma (0 : Fin 2) * (sigma (1 : Fin 2))⁻¹) ^ 2

/-- The trivial braid `1 ∈ B₂ = BraidGrp 1`. -/
def trivialBraid : BraidGrp 1 := 1

/-! ## Writhe values

The writhe (exponent sum) homomorphism sends each generator to `1 ∈ ℤ`
(written multiplicatively as `Multiplicative.ofAdd 1`). -/

/-
Writhe detects the creative braid: its exponent sum is `3`.
-/
theorem writhe_creativeBraid :
    writhe 1 creativeBraid = Multiplicative.ofAdd (3 : ℤ) := by
  erw [ map_pow ]

/-
The trivial braid has writhe `0`.
-/
theorem writhe_trivialBraid :
    writhe 1 trivialBraid = 1 := by
  exact map_one _

/-
Writhe is blind to the confused braid: its balanced crossings cancel, giving
    exponent sum `0`.
-/
theorem writhe_confusedBraid :
    writhe 2 confusedBraid = 1 := by
  simp +decide

/-! ## Nontriviality of the confused braid

Although its writhe vanishes, the confused braid is not the trivial braid: its
image under the quotient `toSymm` to the symmetric group `S₃` is a nontrivial
permutation (a `3`-cycle). -/

/-
The image of the confused braid under `toSymm` is not the identity
    permutation of `Fin 3`.
-/
theorem toSymm_confusedBraid_ne_one :
    toSymm 2 confusedBraid ≠ 1 := by
  simp +decide

/-- The confused braid is nontrivial: it differs from the trivial braid of its
    own group `BraidGrp 2`, even though (by `writhe_confusedBraid`) its writhe
    is `0`, the same as the writhe of the trivial braid. -/
theorem confusedBraid_ne_trivial : confusedBraid ≠ (1 : BraidGrp 2) := by
  intro h
  exact toSymm_confusedBraid_ne_one (by rw [h]; exact map_one _)

/-! ## Summary: writhe detects creativity but is blind to confusion -/

/-- **Writhe is an information invariant that detects creativity but is blind to
    confusion.**

    * `writhe creativeBraid = 3 ≠ 0`: the creative braid is detected.
    * `writhe confusedBraid = 0 = writhe trivialBraid`: writhe cannot tell the
      confused braid apart from the trivial braid.
    * Yet `confusedBraid ≠ 1`: the confused braid really is nontrivial. -/
theorem writhe_detects_creativity_blind_to_confusion :
    writhe 1 creativeBraid = Multiplicative.ofAdd (3 : ℤ) ∧
    writhe 1 trivialBraid = 1 ∧
    writhe 2 confusedBraid = 1 ∧
    confusedBraid ≠ (1 : BraidGrp 2) :=
  ⟨writhe_creativeBraid, writhe_trivialBraid, writhe_confusedBraid,
    confusedBraid_ne_trivial⟩

end CognitiveBraids
end BraidGroup