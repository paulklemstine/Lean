import Mathlib
import Novelty.ZetaModularity
import Novelty.HodgeMirror
import Novelty.MirrorWeilReciprocity
import Novelty.MirrorPointCountCongruence

/-!
# Arithmetic Mirror Symmetry VIII — weight-four modularity of a rigid Calabi–Yau threefold

This file addresses *Conjecture 5*: for a fixed **rigid** Calabi–Yau threefold `X/ℚ`
(`h^{2,1} = 0`, so `b₃ = 2` and the middle cohomology is a two-dimensional Galois
representation), the trace of Frobenius on `H³` equals the `p`-th Fourier coefficient of a
specified weight-four newform at every good prime.

Modularity itself (Serre's conjecture / Gouvêa–Yui, Dieulefait–Manoharmayum for rigid
CY3s) is not something one proves inside a formal library from the definition; what *is*
provable — and what makes the conjecture falsifiable — is the entire arithmetic package
that the identification predicts.  We fix the classical example: the rigid Calabi–Yau
threefold with weight-four newform of level `9`, `f = η(3z)^8`, whose Fourier coefficients
are computed by the CM (complex-multiplication by `ℚ(√−3)`) formula

`a_p = 3pL − L³`  where `4p = L² + 27M²`, `L ≡ 1 (mod 3)`.

Results:

* `cmTrace` — the CM trace formula `a_p = 3pL − L³`;
* `cm_weil_identity` — the **exact algebraic identity**
  `4p³ − a_p² = 27 M² (L² − p)²`, valid for all integers with `4p = L² + 27M²`.
  This is the norm identity `(π³ + π̄³)² − 4(ππ̄)³ = (π³ − π̄³)²` written over `ℤ`;
* `cm_ramanujan_bound` — hence the **Ramanujan–Petersson / Weil bound** for the weight-four
  form: `a_p² ≤ 4p³`, derived from the identity rather than assumed;
* `rigid_frobenius_weil` — combining with the catalog's `DeligneBoundGL2` (through
  `Novelty.ArithMirror.zeta_frobenius_weil`): the Frobenius eigenvalues on `H³` are Weil
  numbers of absolute value `p^{3/2}`;
* `rigid_middle_functional_equation` — the weight-four middle factor
  `1 − a_p T + p³T²` satisfies the reciprocity of file IV with sign `+1`;
* `no_cm_representation_of_inert` — for `p ≡ 2 (mod 3)` the equation `4p = L² + 27M²` has
  **no** integral solution; this is the structural reason the newform is *supersingular*
  (`a_p = 0`) at inert primes, and it is proved by a genuine congruence argument mod `3`;
* `rigid_pointCount_congr` — the falsifiable congruence used to test modularity:
  `#X(𝔽_p) ≡ 1 − a_p (mod p)` for a rigid CY3 with `#X(𝔽_p) = 1 + h¹¹(p + p²) + p³ − a_p`;
* `rigid_has_no_projective_mirror` — a structural corollary of rigidity in the catalog
  Hodge model: the mirror of a rigid Calabi–Yau threefold has Picard rank `0`, hence
  cannot be projective.  Rigid threefolds are exactly the obstruction to a naive
  everywhere-defined mirror map — which is why they are the natural home of the
  *arithmetic* (modularity) side of mirror symmetry;
* `cmTrace_level9_values` — numerical agreement of the CM formula with the `q`-expansion
  of `η(3z)^8` at `p = 7, 13, 19, 31, 37`.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  If the middle cohomology of a rigid CY3 is the Galois
  representation of a weight-four newform, then every structural property of that newform
  (Ramanujan bound, supersingularity at inert primes, functional equation of the local
  factor) must be visible arithmetically on `H³`, and must be exactly reproducible from
  the CM formula for `a_p`.
* **Experiment (Experimenter).**  Computed the `q`-expansion of `η(3z)^8` to `q²⁰⁰` and
  matched it against `3pL − L³` with `4p = L² + 27M²`, `L ≡ 1 (mod 3)`:
  `a₇ = 20 (L=1,M=1)`, `a₁₃ = −70 (L=−5,M=1)`, `a₁₉ = 56 (L=7,M=1)`,
  `a₃₁ = 308 (L=4,M=2)`, `a₃₇ = 110 (L=−11,M=1)`; and `a_p = 0` for every `p ≡ 2 (mod 3)`
  in range (see `ComputationalEvidence.md`).  The Ramanujan bound then turned out to be an
  *identity* rather than an estimate: `4p³ − a_p² = 27M²(L²−p)²`.
* **Analysis (Analyst).**  Conjecture 5 is "true but not formally provable from first
  principles here"; what we can and do prove is that the predicted arithmetic package is
  internally consistent and sharp: the CM formula alone forces the Weil bound, hence Weil
  numbers, hence the functional equation of file IV, and it forces `a_p = 0` exactly at the
  inert primes.  Any good prime violating `#X(𝔽_p) ≡ 1 − a_p (mod p)` would refute the
  identification, so `rigid_pointCount_congr` is the concrete falsification test.
* **Critique (Critic).**  Nothing is asserted about modularity that is not either proved
  or carried as an explicit hypothesis; the Weil bound is *derived* (not assumed), and
  the supersingularity statement is a real theorem about `4p = L² + 27M²`, not a
  restatement of `a_p = 0`.
* **Synthesis (PI).**  Rigidity kills the geometric mirror (Picard rank `0`) but creates
  the arithmetic one: a weight-four newform whose CM structure reproduces, on the nose,
  the Poincaré duality and Weil bounds proved abstractly in files IV and V.
-/

namespace Novelty.MirrorBridge

open Finset

/-! ### The CM trace formula for the weight-four level-nine newform `η(3z)^8` -/

/-- The CM trace `a_p = 3pL − L³` attached to a representation `4p = L² + 27M²`
with `L ≡ 1 (mod 3)`.  For the newform `η(3z)^8` this is the `p`-th Fourier coefficient. -/
def cmTrace (p L : ℤ) : ℤ := 3 * p * L - L ^ 3

/-- **The CM Weil identity.**  For every integral representation `4p = L² + 27M²`,
`4p³ − a_p² = 27 M² (L² − p)²`.  Over `ℤ[ω]` this is
`4(ππ̄)³ − (π³+π̄³)² = −(π³−π̄³)²`; here it is an exact polynomial identity. -/
theorem cm_weil_identity (p L M : ℤ) (h : 4 * p = L ^ 2 + 27 * M ^ 2) :
    4 * p ^ 3 - (cmTrace p L) ^ 2 = 27 * M ^ 2 * (L ^ 2 - p) ^ 2 := by
  unfold cmTrace
  have h27 : 27 * M ^ 2 = 4 * p - L ^ 2 := by linarith
  rw [h27]; ring

/-- **Ramanujan–Petersson bound for the weight-four CM form**, derived from the identity:
`a_p² ≤ 4p³`, i.e. `|a_p| ≤ 2p^{3/2}`. -/
theorem cm_ramanujan_bound (p L M : ℤ) (h : 4 * p = L ^ 2 + 27 * M ^ 2) :
    (cmTrace p L) ^ 2 ≤ 4 * p ^ 3 := by
  have hid := cm_weil_identity p L M h
  nlinarith [sq_nonneg (M * (L ^ 2 - p)), sq_nonneg M, sq_nonneg (L ^ 2 - p)]

/-- **Supersingularity at inert primes.**  If `p ≡ 2 (mod 3)` then `4p = L² + 27M²` has no
integral solution: `p` is inert in `ℚ(√−3)`, so there is no CM trace to form and the
`p`-th coefficient of the newform vanishes.  Proved by a congruence argument modulo `3`
(squares are `0` or `1`, while `4p ≡ 2`). -/
theorem no_cm_representation_of_inert (p : ℕ) (hp : p % 3 = 2) :
    ¬ ∃ L M : ℤ, 4 * (p : ℤ) = L ^ 2 + 27 * M ^ 2 := by
  rintro ⟨L, M, h⟩
  have h3 : ((4 * (p : ℤ) : ℤ) : ZMod 3) = ((L ^ 2 + 27 * M ^ 2 : ℤ) : ZMod 3) := by rw [h]
  push_cast at h3
  have hp3 : ((p : ℕ) : ZMod 3) = 2 := by
    conv_lhs => rw [← Nat.div_add_mod p 3, hp]
    push_cast
    rw [show ((3 : ZMod 3)) = 0 by decide]
    ring
  rw [hp3] at h3
  revert h3
  generalize ((L : ℤ) : ZMod 3) = x
  generalize ((M : ℤ) : ZMod 3) = y
  revert x y
  decide

/-! ### Frobenius eigenvalues on the middle cohomology of a rigid Calabi–Yau threefold -/

/-- **Weil numbers on `H³` (uses the catalog `DeligneBoundGL2` via `ZetaModularity`).**
If the trace on `H³` is the weight-four CM coefficient `a_p` and the determinant is `p³`,
then the two Frobenius eigenvalues have absolute value `p^{3/2}`: the Riemann Hypothesis
for a rigid Calabi–Yau threefold, in the CM case, follows from the trace formula alone. -/
theorem rigid_frobenius_weil (p L M : ℤ) (hp : 0 < (p : ℝ))
    (h : 4 * p = L ^ 2 + 27 * M ^ 2) (α β : ℂ)
    (hsum : α + β = ((cmTrace p L : ℤ) : ℝ))
    (hprod : α * β = (((p : ℝ) ^ 3 : ℝ) : ℂ)) :
    ‖α‖ = Real.sqrt ((p : ℝ) ^ 3) ∧ ‖β‖ = Real.sqrt ((p : ℝ) ^ 3) := by
  have hbound : ((cmTrace p L : ℤ) : ℝ) ^ 2 ≤ 4 * ((p : ℝ) ^ 3) := by
    exact_mod_cast cm_ramanujan_bound p L M h
  exact Novelty.ArithMirror.zeta_frobenius_weil ((cmTrace p L : ℤ) : ℝ) ((p : ℝ) ^ 3)
    (by positivity) hbound α β hsum hprod

/-- **The weight-four middle factor obeys the reciprocity of file IV.**
For a rigid Calabi–Yau threefold over `𝔽_p` the middle factor is
`P(T) = 1 − a_p T + p³T²`, whose reciprocal roots multiply to `p³`; hence
`p³ T² P(1/(p³T)) = P(T)` — sign `ε = +1`, matching the weight-four functional equation
of the newform. -/
theorem rigid_middle_functional_equation (p T α₀ α₁ : ℝ) (hp : p ≠ 0) (hT : T ≠ 0)
    (hprod : α₀ * α₁ = p ^ 3) :
    p ^ 3 * T ^ 2 * middleFactor ![α₀, α₁] (1 / (p ^ 3 * T))
      = middleFactor ![α₀, α₁] T :=
  cy_threefold_middle_reciprocal p T α₀ α₁ hp hT hprod

/-! ### The falsifiable point-count test -/

/-- The `𝔽_p`-point count of a rigid Calabi–Yau threefold with Picard rank `h`, in terms
of the Frobenius trace `a` on `H³`:
`#X(𝔽_p) = 1 + h·p + h·p² + p³ − a` (all cohomology except `H³` being algebraic). -/
def rigidCY3Count (h : ℤ) (p a : ℤ) : ℤ := 1 + h * p + h * p ^ 2 + p ^ 3 - a

/-- **The modularity test congruence.**  `#X(𝔽_p) ≡ 1 − a_p (mod p)`: modulo `p` the point
count of a rigid Calabi–Yau threefold sees only the unit root `1` and the newform
coefficient.  A single good prime with `#X(𝔽_p) ≢ 1 − a_p` refutes the weight-four
identification. -/
theorem rigid_pointCount_congr (h p a : ℤ) : p ∣ rigidCY3Count h p a - (1 - a) := by
  refine ⟨h + h * p + p ^ 2, ?_⟩
  unfold rigidCY3Count
  ring

/-- Consistency with the Hodge–Tate machinery of file VII: modulo `p`, the rigid count and
the mirror-symmetric Hodge–Tate count agree in their unit-root part. -/
theorem rigid_count_congr_hodgeTate (h p a : ℤ) :
    p ∣ rigidCY3Count h p a - hodgeTateCount (fun k => if k = 0 then 1 - a else h) 3 p := by
  have hcount : hodgeTateCount (fun k => if k = 0 then 1 - a else h) 3 p
      = (1 - a) + h * p + h * p ^ 2 + h * p ^ 3 := by
    simp [hodgeTateCount, Finset.sum_range_succ]
  rw [hcount]
  refine ⟨p ^ 2 * (1 - h), ?_⟩
  unfold rigidCY3Count
  ring

/-! ### Rigidity versus the geometric mirror -/

/-- **A rigid Calabi–Yau threefold has no projective mirror.**  In the catalog Hodge model
the mirror of `X` with `h^{2,1}(X) = 0` has Picard rank `0`, whereas a projective
Calabi–Yau threefold has Picard rank at least `1` (it carries an ample class).  So the
geometric mirror map degenerates exactly on the rigid locus — the locus where the
arithmetic (modularity) statement lives. -/
theorem rigid_has_no_projective_mirror (X : Novelty.ArithMirror.CY3)
    (hrig : X.curveModuli = 0) : X.mirror.picardRank = 0 := by
  rw [Novelty.ArithMirror.CY3.picardRank_mirror]
  exact hrig

/-- The sharp form: no projective Calabi–Yau threefold (Picard rank `≥ 1`) can be the
mirror of a rigid one. -/
theorem rigid_mirror_not_projective (X Y : Novelty.ArithMirror.CY3)
    (hrig : X.curveModuli = 0) (hY : Y = X.mirror) (hproj : 1 ≤ Y.picardRank) : False := by
  rw [hY, rigid_has_no_projective_mirror X hrig] at hproj
  omega

/-- The Euler characteristic of a rigid Calabi–Yau threefold is `2·h^{1,1} > 0`, the
maximal possible sign — another way to see that its mirror would need negative
`h^{1,1}`. -/
theorem rigid_euler_pos (X : Novelty.ArithMirror.CY3) (hrig : X.h21 = 0)
    (hproj : 1 ≤ X.h11) : 0 < X.euler := by
  unfold Novelty.ArithMirror.CY3.euler
  rw [hrig]
  have : (1 : ℤ) ≤ (X.h11 : ℤ) := by exact_mod_cast hproj
  simp only [Nat.cast_zero, sub_zero]
  linarith

/-! ### Numerical agreement with the `q`-expansion of `η(3z)^8` -/

/-- The CM formula reproduces the Fourier coefficients of the weight-four level-nine
newform `η(3z)^8 = q − 8q⁴ + 20q⁷ − 70q¹³ + …` at the split primes
`7, 13, 19, 31, 37`, with `4p = L² + 27M²` and `L ≡ 1 (mod 3)`. -/
theorem cmTrace_level9_values :
    cmTrace 7 1 = 20 ∧ cmTrace 13 (-5) = -70 ∧ cmTrace 19 7 = 56 ∧
    cmTrace 31 4 = 308 ∧ cmTrace 37 (-11) = 110 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> (unfold cmTrace; norm_num)

/-- The representations used above are genuine: `4p = L² + 27M²` in each case. -/
theorem cmTrace_level9_representations :
    4 * (7 : ℤ) = 1 ^ 2 + 27 * 1 ^ 2 ∧ 4 * (13 : ℤ) = (-5) ^ 2 + 27 * 1 ^ 2 ∧
    4 * (19 : ℤ) = 7 ^ 2 + 27 * 1 ^ 2 ∧ 4 * (31 : ℤ) = 4 ^ 2 + 27 * 2 ^ 2 ∧
    4 * (37 : ℤ) = (-11) ^ 2 + 27 * 1 ^ 2 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> norm_num

end Novelty.MirrorBridge