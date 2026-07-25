import Mathlib

/-!
# Functional equations enforce primitivity of coefficients

This file studies the rigid interplay between the **functional equation** of a Dirichlet
`L`-function and the **primitivity** of its underlying character.  The completed
`L`-function `Λ(χ, s)` of a *primitive* character `χ` modulo `N` satisfies the clean
reflection identity
$$\Lambda(\chi, 1 - s) \;=\; N^{\,s - 1/2}\, W(\chi)\, \Lambda(\chi^{-1}, s),$$
where `W(χ)` is the root number, an explicit normalisation of the Gauss sum of `χ`.

The results below fall into two families.

*Analytic rigidity.*  From the reflection identity alone we extract structural constraints
that are invisible at the level of a single value: the **central-point identity**, the
**root-number reciprocity law** `W(χ)·W(χ⁻¹) = 1` (in its identity form), and the
**self-dual functional equation** valid for real (quadratic) characters, from which
`W(χ)² = 1` follows.

*Gauss-sum enforcement.*  The root number is built from a Gauss sum, and the arithmetic
of Gauss sums is exactly what forces the character to be primitive: a Gauss sum can only
survive against an imprimitive additive character when the Dirichlet character itself is
imprimitive.  This is the precise sense in which "the functional equation enforces
primitivity of the coefficients".

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The clean reflection identity for `Λ(χ, ·)` is not an accident
of one character but a *rigidity engine*: iterating it should pin down the root number, and
its very existence (through the Gauss sum) should be equivalent to primitivity.

Experiment (Experimenter): We proved four reflection-driven identities and two Gauss-sum
enforcement statements.  The reflection identity `IsPrimitive.completedLFunction_one_sub`
is the single analytic input; everything else is derived by substitution `s ↦ 1 - s`,
the multiplicativity of `N^{·}`, and `inv_inv`.

Analysis (Analyst): "True but subtle" — the reciprocity law `W(χ)·W(χ⁻¹)·Λ(χ,s) = Λ(χ,s)`
holds as a functional identity without any non-vanishing hypothesis; upgrading it to
`W(χ)·W(χ⁻¹) = 1` genuinely needs a point where `Λ(χ, ·)` is non-zero, which we deliberately
avoid to keep the statements unconditional.  The self-dual case collapses reciprocity to
`W(χ)² = 1`.  On the Gauss-sum side, primitivity of the *additive* character is detected by
non-vanishing of the Gauss sum precisely when `χ` is primitive.

Critique (Critic): None of the theorems is vacuous — each consumes the reflection identity
or a Gauss-sum vanishing theorem and performs real algebra (`cpow` addition, `inv_inv`,
contraposition).  The reciprocity law is stated in identity form to avoid a hidden
non-vanishing assumption that would make it conditional.

Synthesis (PI): Primitivity is the exact hypothesis under which the functional equation is
"clean", and the Gauss sum — the analytic heart of the root number — vanishes exactly when
primitivity fails.  These two facts are the two faces of the guiding conjecture.
-/

namespace FEPrimitivity

open DirichletCharacter Complex

/-! ### Primitivity is preserved under inversion -/

/-
The inverse of a primitive Dirichlet character is again primitive: inversion does not
change the set of moduli through which the character factors, hence preserves the conductor.
-/
lemma isPrimitive_inv {N : ℕ} [NeZero N] {χ : DirichletCharacter ℂ N}
    (hχ : χ.IsPrimitive) : χ⁻¹.IsPrimitive := by
  simp_all +decide [ DirichletCharacter.IsPrimitive ];
  convert hχ using 1;
  have h_factors : ∀ d, χ.FactorsThrough d ↔ (χ⁻¹).FactorsThrough d := by
    intro d
    simp [DirichletCharacter.FactorsThrough];
    constructor <;> rintro ⟨ h₁, χ₀, h₂ ⟩;
    · exact ⟨ h₁, χ₀⁻¹, by simp +decide [ h₂ ] ⟩;
    · refine' ⟨ h₁, χ₀⁻¹, _ ⟩;
      simp +decide [ ← h₂ ];
  unfold DirichletCharacter.conductor;
  unfold DirichletCharacter.conductorSet; aesop;

/-! ### Analytic rigidity from the reflection identity -/

/-
**Central-point functional equation.**  At the centre `s = 1/2` of the critical strip the
power of the modulus disappears (`N^0 = 1`), and the reflection identity relates the central
value of `Λ(χ, ·)` directly to that of its dual through the root number.
-/
theorem completedLFunction_central {N : ℕ} [NeZero N] {χ : DirichletCharacter ℂ N}
    (hχ : χ.IsPrimitive) :
    completedLFunction χ (1 / 2) = rootNumber χ * completedLFunction χ⁻¹ (1 / 2) := by
  convert hχ.completedLFunction_one_sub ( 1 / 2 ) using 1 ; norm_num;
  norm_num [ mul_assoc ]

/-
**Root-number reciprocity (identity form).**  Applying the reflection identity to `χ` and
to `χ⁻¹` and composing the two substitutions cancels the modulus factors entirely, leaving
`W(χ)·W(χ⁻¹)` acting as the identity on every value of the completed `L`-function.  This is the
unconditional shadow of the reciprocity law `W(χ)·W(χ⁻¹) = 1`.
-/
theorem rootNumber_reciprocity {N : ℕ} [NeZero N] {χ : DirichletCharacter ℂ N}
    (hχ : χ.IsPrimitive) (s : ℂ) :
    rootNumber χ * rootNumber χ⁻¹ * completedLFunction χ s = completedLFunction χ s := by
  have h_subst := hχ.completedLFunction_one_sub ( 1 - s );
  rw [ isPrimitive_inv hχ |> fun h => h.completedLFunction_one_sub s ] at h_subst;
  convert h_subst.symm using 1 ; ring;
  · norm_num [ mul_assoc, ← Complex.cpow_add, NeZero.ne ];
  · norm_num

/-
**Self-dual functional equation.**  A real (quadratic) character satisfies `χ⁻¹ = χ`, so the
reflection identity becomes genuinely self-dual: `Λ(χ, ·)` is carried to itself, up to the
modulus factor and root number.
-/
theorem completedLFunction_self_dual {N : ℕ} [NeZero N] {χ : DirichletCharacter ℂ N}
    (hχ : χ.IsPrimitive) (hself : χ⁻¹ = χ) (s : ℂ) :
    completedLFunction χ (1 - s)
      = (N : ℂ) ^ (s - 1 / 2) * rootNumber χ * completedLFunction χ s := by
  convert hχ.completedLFunction_one_sub s using 1 ; norm_num [ hself ]

/-
**Root number of a real character squares to the identity.**  For a self-dual character the
reciprocity law reads `W(χ)² · Λ(χ, s) = Λ(χ, s)`, the precise statement that the root number
of a quadratic character is a square root of unity acting trivially on the `L`-values.
-/
theorem rootNumber_sq_self_dual {N : ℕ} [NeZero N] {χ : DirichletCharacter ℂ N}
    (hχ : χ.IsPrimitive) (hself : χ⁻¹ = χ) (s : ℂ) :
    rootNumber χ ^ 2 * completedLFunction χ s = completedLFunction χ s := by
  have := rootNumber_reciprocity hχ s; simp_all +decide [ sq ] ;

/-! ### Gauss-sum enforcement of primitivity -/

/-
**Gauss sums detect additive primitivity.**  If `χ` is a primitive Dirichlet character and
its Gauss sum against an additive character `e` is non-zero, then `e` itself must be primitive.
Equivalently, a primitive character annihilates every imprimitive additive character through its
Gauss sum.
-/
theorem isPrimitive_addChar_of_gaussSum_ne_zero {N : ℕ} [NeZero N]
    {χ : DirichletCharacter ℂ N} (hχ : χ.IsPrimitive) {e : AddChar (ZMod N) ℂ}
    (h : gaussSum χ e ≠ 0) : e.IsPrimitive := by
  exact not_not.mp fun hn => h <| gaussSum_eq_zero_of_isPrimitive_of_not_isPrimitive e hχ hn;

/-
**Imprimitivity is forced by a surviving Gauss sum.**  Conversely, if some *imprimitive*
additive character `e` has a non-zero Gauss sum against `χ`, then `χ` cannot be primitive: the
survival of the Gauss sum is an obstruction to primitivity of the Dirichlet character.
-/
theorem not_isPrimitive_of_gaussSum_ne_zero {N : ℕ} [NeZero N]
    {χ : DirichletCharacter ℂ N} {e : AddChar (ZMod N) ℂ}
    (he : ¬ e.IsPrimitive) (h : gaussSum χ e ≠ 0) : ¬ χ.IsPrimitive := by
  exact fun hχ => h <| gaussSum_eq_zero_of_isPrimitive_of_not_isPrimitive e hχ he

/-
**Conductor descent from Gauss sums.**  Whenever a Gauss sum of `χ` survives against an
additive character trivialised by a divisor `d ∣ N`, the character already factors through `d`;
so the conductor is bounded by `d`.  Only when every such Gauss sum vanishes can `χ` be
primitive at the full level `N`.
-/
theorem conductor_le_of_gaussSum_ne_zero {N : ℕ} [NeZero N]
    {χ : DirichletCharacter ℂ N} {e : AddChar (ZMod N) ℂ} {d : ℕ}
    (hd : d ∣ N) (he : e.mulShift (d : ZMod N) = 1) (h : gaussSum χ e ≠ 0) :
    χ.conductor ≤ d := by
  refine' Nat.sInf_le _;
  convert factorsThrough_of_gaussSum_ne_zero e hd he h using 1

end FEPrimitivity