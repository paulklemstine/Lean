/-
# Structure of radical 2-isogeny walks

Three structural questions about a radical isogeny walk are settled here.

1. **Does the walk backtrack?**  A 2-isogeny walk is useful only if consecutive
   steps are not dual to each other.  `radTwoIso_two_torsion_image` computes the
   image of the *non-kernel* two-torsion of `E_A`: it is the point `(-α/2, 0)` of
   the target.  Backtracking would mean taking that point as the next kernel,
   whereas the radical formula always takes `(0,0)`, which by
   `radTwoIso_four_torsion` is the image of a *four*-torsion point.
   `radicalWalk_nonbacktracking` records that these two points are distinct, so a
   radical walk never immediately retraces its step.

2. **Do two steps compose?**  `radTwoIso_two_step` chains two radical steps
   through the intermediate quadratic-twist normalisation, giving the
   end-to-end correctness statement for a length-two walk (i.e. a cyclic
   4-isogeny).

3. **Can a walk stand still?**  `modPoly2_diagonal_factor` factors the diagonal
   of the modular polynomial,
   `Φ₂(j,j) = -(j-8000)(j+3375)²(j-1728)`,
   and `radical_fixed_point_classification` deduces that a radical step can
   return to the same `j`-invariant only at `j ∈ {1728, 8000, -3375}` — the
   three CM `j`-invariants of discriminants `-4`, `-8`, `-7`.  Everywhere else
   the walk genuinely moves.
-/
import Cryptography.IsogenySIDH.SupersingularRadicalExistence

set_option maxHeartbeats 1000000

namespace Cryptography.IsogenySIDH

variable {K : Type*} [Field K]

/-! ## Non-backtracking -/

/-- The image of a non-kernel two-torsion point of `E_A` under the radical
step.  Such a point has `x² + A x + 1 = 0` and `y = 0`, and lands on
`(-α/2, 0)`. -/
theorem radTwoIso_two_torsion_image {A α x : K} (hα : α ≠ 0) (htwo : (2 : K) ≠ 0)
    (hsq : α ^ 2 = A + 2) (hx : x ≠ 0) (hroot : x ^ 2 + A * x + 1 = 0) :
    radTwoIso α (x, 0) = (-α / 2, 0) := by
  refine Prod.ext ?_ ?_
  · show (x - 1) ^ 2 / (2 * α * x) = -α / 2
    rw [div_eq_div_iff (by exact mul_ne_zero (mul_ne_zero htwo hα) hx) htwo]
    linear_combination (2 : K) * hroot + 2 * x * hsq
  · show (0 : K) * (x ^ 2 - 1) / x ^ 2 = 0
    simp

/-- **Radical walks do not backtrack.**  The kernel generator of the next
radical step, `(0,0)`, is different from the image of the non-kernel
two-torsion of the source curve, which is where the dual isogeny's kernel
sits.  Hence the second step of a radical walk is never the dual of the
first. -/
theorem radicalWalk_nonbacktracking {A α x : K} (hα : α ≠ 0) (htwo : (2 : K) ≠ 0)
    (hsq : α ^ 2 = A + 2) (hx : x ≠ 0) (hroot : x ^ 2 + A * x + 1 = 0) (y : K) :
    radTwoIso α (x, 0) ≠ radTwoIso α (1, y) := by
  rw [radTwoIso_two_torsion_image hα htwo hsq hx hroot, radTwoIso_four_torsion]
  intro h
  have h1 : -α / 2 = 0 := congrArg Prod.fst h
  rw [div_eq_zero_iff] at h1
  rcases h1 with h1 | h1
  · exact hα (neg_eq_zero.mp h1)
  · exact htwo h1

/-! ## Two-step composition (cyclic 4-isogeny) -/

/-- **Two radical steps compose.**  Starting from an affine point of `E_A`, one
radical step lands on the twisted model with parameter `A₁ = radTwoParam A α`;
after rescaling by a square root `r` of the twist coefficient, a second radical
step with radical `α₁` lands on the twisted model with parameter
`radTwoParam A₁ α₁`.  This is the end-to-end correctness statement for a
length-two radical walk. -/
theorem radTwoIso_two_step {A α α₁ r x y : K}
    (hα : α ≠ 0) (hsq : α ^ 2 = A + 2) (hx : x ≠ 0)
    (hP : OnMontgomery A (x, y))
    (hr : r ^ 2 = radTwoTwist α)
    (hα₁ : α₁ ≠ 0) (hsq₁ : α₁ ^ 2 = radTwoParam A α + 2)
    (hx₁ : (radTwoIso α (x, y)).1 ≠ 0) :
    genMont (radTwoTwist α₁) (radTwoParam (radTwoParam A α) α₁)
      (radTwoIso α₁ (radicalNormalize r (radTwoIso α (x, y)))) := by
  have hstep1 : genMont (radTwoTwist α) (radTwoParam A α) (radTwoIso α (x, y)) :=
    radTwoIso_mem hα hsq hx hP
  have huntwist : OnMontgomery (radTwoParam A α)
      (radicalNormalize r (radTwoIso α (x, y))) := genMont_untwist hr hstep1
  have hx' : (radicalNormalize r (radTwoIso α (x, y))).1 ≠ 0 := hx₁
  exact radTwoIso_mem hα₁ hsq₁ hx' huntwist

/-! ## Fixed points of the walk on the `j`-line -/

/-- **Diagonal of the modular polynomial.**  `Φ₂(j,j)` factors completely, with
roots `8000`, `-3375` (double) and `1728`.  These are exactly the `j`-invariants
of the elliptic curves with complex multiplication by an order of discriminant
`-8`, `-7` and `-4`. -/
theorem modPoly2_diagonal_factor (j : K) :
    modPoly2 j j = -(j - 8000) * (j + 3375) ^ 2 * (j - 1728) := by
  simp only [modPoly2]; ring

/-- **A radical step almost never stands still.**  If a radical step returns to
the same point of the `j`-line, then that `j`-invariant is one of the three CM
values `1728`, `8000`, `-3375`. -/
theorem radical_fixed_point_classification {A : K} (hd : A ^ 2 - 4 ≠ 0)
    (hfix : jQuot A = jMont A) :
    jMont A = 8000 ∨ jMont A = -3375 ∨ jMont A = 1728 := by
  have h0 : modPoly2 (jMont A) (jMont A) = 0 := by
    have hstep := modPoly2_jMont_jQuot hd
    rwa [hfix] at hstep
  rw [modPoly2_diagonal_factor] at h0
  rcases mul_eq_zero.mp h0 with h1 | h1
  · rcases mul_eq_zero.mp h1 with h2 | h2
    · left; linear_combination -h2
    · right; left; linear_combination sq_eq_zero_iff.mp h2
  · right; right; linear_combination h1

/-- Contrapositive form: away from the three CM values, every radical step
genuinely moves the `j`-invariant, so the walk makes progress. -/
theorem radical_step_moves {A : K} (hd : A ^ 2 - 4 ≠ 0)
    (h1 : jMont A ≠ 8000) (h2 : jMont A ≠ -3375) (h3 : jMont A ≠ 1728) :
    jQuot A ≠ jMont A := by
  intro hfix
  rcases radical_fixed_point_classification hd hfix with h | h | h
  · exact h1 h
  · exact h2 h
  · exact h3 h

/-- Along a nonsingular radical walk that avoids the three CM `j`-invariants,
consecutive curves are never isomorphic: the walk is strictly progressing at
every step. -/
theorem radChain_strictly_progressing {r : ℕ → K} {A : K} (htwo : (2 : K) ≠ 0)
    (h : NonsingularWalk r A) (n : ℕ)
    (h1 : jMont (radChain r A n) ≠ 8000)
    (h2 : jMont (radChain r A n) ≠ -3375)
    (h3 : jMont (radChain r A n) ≠ 1728) :
    jMont (radChain r A (n + 1)) ≠ jMont (radChain r A n) := by
  rw [radChain_jMont_eq_jQuot htwo h n]
  exact radical_step_moves (h.2 n) h1 h2 h3

end Cryptography.IsogenySIDH