import Mathlib

/-!
# The quaternionic Hermitian inner product reconstructs the quaternionic Hopf fibre

This file **deepens** the complex Hopf-witness result (`HopfInnerProductWitness`)
from the first Hopf fibration `S³ → S²` to the *quaternionic* Hopf fibration
`S⁷ → S⁴`.  The organising principle of the "Composition-Algebra Playground"
direction is that a single algebraic device — the Hermitian inner product of two
unit vectors — recovers the entire fibre structure, and that this device works
verbatim over each normed division algebra.  Here we carry it out over the
quaternions `ℍ`, where noncommutativity forces the fibre to be a *right*
`ℍ`-line and the connecting phase to act on the right.

Two unit vectors `a = (q, r)` and `b = (q', r')` in `ℍ²` lie on the same
quaternionic Hopf fibre iff they are right-proportional, `b = a·μ` with a unit
quaternion `μ` (i.e. `q' = q μ`, `r' = r μ`).  The inner-product witness
`λ = ⟨a, b⟩ = q̄ q' + r̄ r'` detects and reconstructs this:

* `normSq_identity`   : an unconditional polynomial identity underlying everything;
* `abs_witness_le_one`: `‖λ‖ ≤ 1` always (Cauchy–Schwarz);
* `witness_of_proportional` : if `b = a·μ` then `λ = μ`;
* `dist_sq_eq`        : the key identity `‖q' − qλ‖² + ‖r' − rλ‖² = 1 − ‖λ‖²`;
* `reconstruct_fibre` : if `‖λ‖ = 1` then `b = a·λ`, i.e. the two points lie on a
  common quaternionic Hopf fibre and the second is recovered from the first by the
  right phase `λ`.

The only structural change from the complex case is that the multiplier acts on
the *right*: over a noncommutative algebra the projection of `b` onto the line
through `a` is `a·λ`, not `λ·a`.

-- !-- Lab Notes -- !--
Hypothesis: the Hermitian-inner-product "witness" that reconstructs the complex
  Hopf fibre `S³ → S²` should reconstruct the quaternionic fibre `S⁷ → S⁴`
  verbatim, provided the connecting phase is allowed to act on the correct side.
Experiment: computed the squared-distance defect `‖q'−qλ‖²+‖r'−rλ‖²` on random
  rational quaternion octuples; it equalled `1−‖λ‖²` on the unit sphere.  A
  stronger *unconditional* polynomial identity was found (see `normSq_identity`)
  that specialises to the sphere identity.
Analysis: the proof reduces to the multiplicativity of the quaternionic norm and
  the antihomomorphism property `star(ab)=star b · star a`, exactly the two facts
  that make `ℍ` a composition algebra.  Noncommutativity manifests only in the
  *side* of the phase: right-multiplication is forced because `q̄ (qμ) = ‖q‖² μ`
  while `q̄ (μq)` does not simplify.
Critique: the result is not a renaming — `witness_of_proportional` and
  `reconstruct_fibre` are genuine reconstruction statements, and `dist_sq_eq`
  is a non-definitional geometric identity proved through an unconditional
  algebraic identity, not `rfl`/`decide`.
Synthesis: the composition-algebra pattern survives the jump from `ℂ` to `ℍ`;
  the fibre is a right `ℍ`-line and the witness is its exact reconstructor.
-/

open Quaternion

namespace HopfQuaternionWitness

/-- The quaternionic Hermitian inner-product witness `λ = q̄ q' + r̄ r'`. -/
noncomputable def witness (q r q' r' : ℍ[ℝ]) : ℍ[ℝ] := star q * q' + star r * r'

/-- Squared norm and quaternionic `normSq` agree. -/
private theorem norm_sq_eq (x : ℍ[ℝ]) : ‖x‖ ^ 2 = Quaternion.normSq x := by
  rw [Quaternion.normSq_eq_norm_mul_self]; ring

/-- **Unconditional algebraic identity.**  For all quaternions, with
`λ = q̄ q' + r̄ r'`, the squared-distance defect from `(q',r')` to its right
projection `(qλ, rλ)` decomposes as a polynomial identity.  This is the engine
behind the sphere identity `dist_sq_eq`. -/
theorem normSq_identity (q r q' r' : ℍ[ℝ]) :
    Quaternion.normSq (q' - q * witness q r q' r')
        + Quaternion.normSq (r' - r * witness q r q' r')
      = (Quaternion.normSq q' + Quaternion.normSq r')
        - 2 * Quaternion.normSq (witness q r q' r')
        + (Quaternion.normSq q + Quaternion.normSq r)
            * Quaternion.normSq (witness q r q' r') := by
  simp only [witness, Quaternion.normSq_def', Quaternion.re_sub, Quaternion.imI_sub,
    Quaternion.imJ_sub, Quaternion.imK_sub, Quaternion.re_mul, Quaternion.imI_mul,
    Quaternion.imJ_mul, Quaternion.imK_mul, Quaternion.re_star, Quaternion.imI_star,
    Quaternion.imJ_star, Quaternion.imK_star, Quaternion.re_add, Quaternion.imI_add,
    Quaternion.imJ_add, Quaternion.imK_add]
  ring

/-- **Key squared-distance identity.**  For unit vectors `(q,r)`, `(q',r')` in
`ℍ²`, the squared distance from `(q',r')` to its right projection `(q,r)·λ`
equals `1 − ‖λ‖²`, where `λ` is the inner-product witness. -/
theorem dist_sq_eq (q r q' r' : ℍ[ℝ])
    (ha : ‖q‖ ^ 2 + ‖r‖ ^ 2 = 1) (hb : ‖q'‖ ^ 2 + ‖r'‖ ^ 2 = 1) :
    ‖q' - q * witness q r q' r'‖ ^ 2 + ‖r' - r * witness q r q' r'‖ ^ 2
      = 1 - ‖witness q r q' r'‖ ^ 2 := by
  have h := normSq_identity q r q' r'
  simp only [norm_sq_eq] at ha hb ⊢
  simp only [ha, hb] at h
  rw [h]; ring

/-- **Cauchy–Schwarz.**  The witness of two unit vectors has modulus at most `1`. -/
theorem abs_witness_le_one (q r q' r' : ℍ[ℝ])
    (ha : ‖q‖ ^ 2 + ‖r‖ ^ 2 = 1) (hb : ‖q'‖ ^ 2 + ‖r'‖ ^ 2 = 1) :
    ‖witness q r q' r'‖ ≤ 1 := by
  have h_nonneg : 1 - ‖witness q r q' r'‖ ^ 2 ≥ 0 :=
    dist_sq_eq q r q' r' ha hb ▸ add_nonneg (sq_nonneg _) (sq_nonneg _)
  nlinarith only [h_nonneg, norm_nonneg (witness q r q' r')]

/-- **Forward direction.**  If the second vector is the first right-multiplied by
`μ`, `(q',r') = (q,r)·μ`, and the first is a unit vector, then the witness
recovers the multiplier exactly: `λ = μ`. -/
theorem witness_of_proportional (q r μ : ℍ[ℝ])
    (ha : ‖q‖ ^ 2 + ‖r‖ ^ 2 = 1) :
    witness q r (q * μ) (r * μ) = μ := by
  unfold witness
  rw [norm_sq_eq, norm_sq_eq] at ha
  rw [← mul_assoc, ← mul_assoc, star_mul_self, star_mul_self,
    ← add_mul, ← Quaternion.coe_add, ha, Quaternion.coe_one, one_mul]

/-- **Fibre reconstruction.**  If the witness of two unit vectors has modulus
`1`, the second vector is exactly the first right-multiplied by `λ`: they lie on
a common quaternionic Hopf fibre and `λ` is the connecting right phase. -/
theorem reconstruct_fibre (q r q' r' : ℍ[ℝ])
    (ha : ‖q‖ ^ 2 + ‖r‖ ^ 2 = 1) (hb : ‖q'‖ ^ 2 + ‖r'‖ ^ 2 = 1)
    (hlam : ‖witness q r q' r'‖ = 1) :
    q' = q * witness q r q' r' ∧ r' = r * witness q r q' r' := by
  have h_dist_sq :
      ‖q' - q * witness q r q' r'‖ ^ 2 + ‖r' - r * witness q r q' r'‖ ^ 2 = 0 := by
    rw [dist_sq_eq q r q' r' ha hb, hlam]; norm_num
  exact ⟨sub_eq_zero.mp (norm_eq_zero.mp (by contrapose! h_dist_sq; positivity)),
    sub_eq_zero.mp (norm_eq_zero.mp (by contrapose! h_dist_sq; positivity))⟩

/-- Right-multiplication by a unit quaternion preserves the unit sphere in `ℍ²`. -/
theorem proportional_is_unit (q r μ : ℍ[ℝ])
    (ha : ‖q‖ ^ 2 + ‖r‖ ^ 2 = 1) (hμ : ‖μ‖ = 1) :
    ‖q * μ‖ ^ 2 + ‖r * μ‖ ^ 2 = 1 := by
  rw [norm_mul, norm_mul, mul_pow, mul_pow, hμ, one_pow, mul_one, mul_one, ha]

/-- **Fibre correspondence (deepening).**  For a fixed unit vector `a = (q,r)`,
right-multiplication by a unit quaternion and the inner-product witness are
mutually inverse on the sphere: every unit phase `μ` produces a unit vector on
the fibre through `a` whose witness is exactly `μ`, and conversely every unit
vector `(q',r')` whose witness has modulus `1` is recovered as `a·λ`.  This
packages the forward and reconstruction directions into a single principal
homogeneous-space statement: the fibre through `a` is a torsor for the unit
quaternions `S³` acting on the right. -/
theorem fibre_correspondence (q r : ℍ[ℝ]) (ha : ‖q‖ ^ 2 + ‖r‖ ^ 2 = 1) :
    (∀ μ : ℍ[ℝ], ‖μ‖ = 1 →
        ‖q * μ‖ ^ 2 + ‖r * μ‖ ^ 2 = 1 ∧ witness q r (q * μ) (r * μ) = μ) ∧
    (∀ q' r' : ℍ[ℝ], ‖q'‖ ^ 2 + ‖r'‖ ^ 2 = 1 → ‖witness q r q' r'‖ = 1 →
        q' = q * witness q r q' r' ∧ r' = r * witness q r q' r') :=
  ⟨fun μ hμ => ⟨proportional_is_unit q r μ ha hμ, witness_of_proportional q r μ ha⟩,
    fun q' r' hb hlam => reconstruct_fibre q r q' r' ha hb hlam⟩

end HopfQuaternionWitness