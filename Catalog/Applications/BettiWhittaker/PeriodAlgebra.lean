/-
# The algebra of the Betti–Whittaker contragredient period relation, and a self-dual obstruction

This file isolates the **algebraic content** of the contragredient period relation
(companion: `NumberTheory/BettiWhittakerContragredientFormal.lean` and the sign analysis in
`Applications/BettiWhittaker/BottomDegreeParity.lean`):

  `p^b(π∨) = (-1)^{b(F,n)} · p^b(π)`,    `b(F,n) = r₁·⌊n²/4⌋ + r₂·n(n-1)/2`.

Working with the periods as honest nonzero complex numbers, we extract three facts that hold for
*any* sign `s` and then specialise to `s = (-1)^{b(F,n)}`:

* **Consistency** (`relation_involutive_forces_sq`): because the contragredient is an involution
  (`(π∨)∨ = π`), applying the relation twice forces `s² = 1`.  The square-root-of-unity property
  of the sign is therefore not an extra hypothesis — it is *forced* by the relation.
* **Self-dual compatibility** (`selfDual_compatible_iff`): for a fixed nonzero period the relation
  is compatible with self-duality `π ≅ π∨` (i.e. `p∨ = p`) **iff** `s = 1`.
* **Self-dual obstruction** (`no_selfDual_of_odd`, `selfDual_iff_even_bDeg`): consequently a
  generic cohomological representation with a nonzero bottom Betti–Whittaker period can be
  self-dual **only when `b(F,n)` is even**.  When `b(F,n)` is odd the sign is `-1` and self-duality
  is impossible.  Combined with the `n mod 4` parity trichotomy of the companion file, this turns
  into explicit congruence conditions on `(n, r₁, r₂)`.

The file is self-contained (`import Mathlib`); it reuses the bottom degree `bDeg` (matching the
companion files) inside the dedicated namespace `BettiWhittaker.Period`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the period sign is not free — involutivity of `π ↦ π∨` should pin down
`s² = 1`, and a *self-dual* `π` should be obstructed whenever the sign is `-1`.  Bold sub-claim:
self-duality is impossible precisely in the odd-`b(F,n)` degrees.

Experiment (Experimenter): modelled the periods as `p, q : ℂ` with `q = s·p`.  Proved
`s² = 1` from `q = s·p` together with the involution `p = s·q` (one `linear_combination`).  Proved
`q = p ↔ s = 1` for `p ≠ 0` by factoring `(s-1)·p = 0`.

Analysis (Analyst): the obstruction is *clean* — it needs only `p ≠ 0` and the relation, no
analytic input.  The arithmetic enters solely through the parity of `b(F,n)`.  Failure mode that
was ruled out: trying to phrase everything in the unit group `ℂˣ` introduced a missing `Neg`
instance; switching to `ℂ` with an explicit `p ≠ 0` hypothesis is cleaner and strictly more
general (it also covers the degenerate `p = 0` case as "no constraint").

Critique (Critic): is `no_selfDual_of_odd` vacuous (could `p` be forced to `0`)?  No — it is a
genuine `q ≠ p` conclusion under `p ≠ 0`.  Adversarial counterexample: if `b(F,n)` is *even* the
obstruction must fail, and indeed `selfDual_iff_even_bDeg` shows self-duality is then permitted —
so the boundary is exactly the parity of `b(F,n)`, not an artefact.

Synthesis (PI): the sign is a forced square root of unity; self-duality lives exactly in the
even-degree locus; oddness is a hard obstruction.
-/
import Mathlib

namespace BettiWhittaker.Period

/-! ## The abstract period relation -/

/-- If a nonzero period `p` is fixed by multiplication by `s`, then `s = 1`. -/
theorem selfDual_forces_sign_one {p s : ℂ} (hp : p ≠ 0) (hself : p = s * p) : s = 1 := by
  have h0 : (s - 1) * p = 0 := by rw [sub_mul, one_mul]; linear_combination -hself
  rcases mul_eq_zero.mp h0 with h | h
  · exact sub_eq_zero.mp h
  · exact absurd h hp

/-- **Consistency of the relation.**  If `q = s·p` (period of `π∨`) and, by involutivity of the
contragredient, also `p = s·q` (period of `(π∨)∨ = π`), then the sign satisfies `s² = 1`.  The
square-root-of-unity property is *forced*, not assumed. -/
theorem relation_involutive_forces_sq {p q s : ℂ} (hp : p ≠ 0)
    (hrel : q = s * p) (hinv : p = s * q) : s ^ 2 = 1 := by
  have hpp : p = s ^ 2 * p := by linear_combination hinv + s * hrel
  exact selfDual_forces_sign_one hp hpp

/-- Applying the relation twice multiplies the period by `s²`. -/
theorem period_apply_twice {p q s : ℂ} (hrel : q = s * p) (hinv : p = s * q) :
    q = s ^ 2 * q := by linear_combination hrel + s * hinv

/-- **Self-dual compatibility.**  For a nonzero period, `π` is self-dual (`p∨ = p`) **iff** the
sign is trivial. -/
theorem selfDual_compatible_iff {p q s : ℂ} (hp : p ≠ 0) (hrel : q = s * p) :
    q = p ↔ s = 1 := by
  constructor
  · intro hself; exact selfDual_forces_sign_one hp (by rw [← hrel, hself])
  · intro hs; rw [hrel, hs, one_mul]

/-! ## The concrete sign `(-1)^{b(F,n)}` and the self-dual obstruction -/

/-- The bottom cohomological degree `b(F,n) = r₁·⌊n²/4⌋ + r₂·n(n-1)/2` (matching the companion
catalog files). -/
def bDeg (n r₁ r₂ : ℕ) : ℕ := r₁ * (n / 2) * ((n + 1) / 2) + r₂ * n * (n - 1) / 2

/-- The contragredient sign as a complex number, `(-1)^{b(F,n)} ∈ ℂ`. -/
noncomputable def contraSignC (n r₁ r₂ : ℕ) : ℂ := (-1) ^ bDeg n r₁ r₂

/-- The complex sign is a square root of unity. -/
theorem contraSignC_sq (n r₁ r₂ : ℕ) : contraSignC n r₁ r₂ ^ 2 = 1 := by
  rw [contraSignC, ← pow_mul, mul_comm, pow_mul]; simp

/-- An odd bottom degree gives sign `-1`. -/
theorem contraSignC_eq_neg_one_of_odd (n r₁ r₂ : ℕ) (h : Odd (bDeg n r₁ r₂)) :
    contraSignC n r₁ r₂ = -1 := by rw [contraSignC, h.neg_one_pow]

/-- The sign is trivial **iff** the bottom degree is even. -/
theorem contraSignC_eq_one_iff_even (n r₁ r₂ : ℕ) :
    contraSignC n r₁ r₂ = 1 ↔ Even (bDeg n r₁ r₂) :=
  neg_one_pow_eq_one_iff_even (by norm_num)

/-- **Self-dual obstruction.**  If `b(F,n)` is odd then the sign is `-1`, so no nonzero bottom
Betti–Whittaker period can be self-dual: the relation `p∨ = (-1)^{b(F,n)} · p` forces `p∨ ≠ p`. -/
theorem no_selfDual_of_odd (n r₁ r₂ : ℕ) (h : Odd (bDeg n r₁ r₂))
    {p q : ℂ} (hp : p ≠ 0) (hrel : q = contraSignC n r₁ r₂ * p) : q ≠ p := by
  intro hself
  have hone : contraSignC n r₁ r₂ = 1 := (selfDual_compatible_iff hp hrel).mp hself
  rw [contraSignC_eq_neg_one_of_odd n r₁ r₂ h] at hone
  norm_num at hone

/-- **Self-duality lives exactly in the even-degree locus.**  For a nonzero period satisfying the
period relation, `π` is self-dual iff `b(F,n)` is even. -/
theorem selfDual_iff_even_bDeg (n r₁ r₂ : ℕ) {p q : ℂ} (hp : p ≠ 0)
    (hrel : q = contraSignC n r₁ r₂ * p) : q = p ↔ Even (bDeg n r₁ r₂) := by
  rw [selfDual_compatible_iff hp hrel, contraSignC_eq_one_iff_even]

end BettiWhittaker.Period