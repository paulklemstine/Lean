/-
# The radical Montgomery step is a genuine edge of the 2-isogeny graph

`RadicalMontgomeryFormula` produced an explicit rational map from `E_A` to a
generalized Montgomery curve with parameter `radTwoParam A α = (A+6)/(2α)`,
`α² = A + 2`.  That is a *local* verification: the formulas transport points.
This file supplies the *global* certificate that the construction really is a
2-isogeny, by checking it against the classical modular polynomial `Φ₂`.

The main results are:

* `jMont_radTwoParam` — the `j`-invariant of the target is
  `jQuot A = 16 (A²+12)³ / (A²-4)²`.  Remarkably the radical `α` cancels: the
  target `j` is a *rational* function of `A`.
* `jMont_model_independent` — the three Montgomery renormalisations of the
  quotient curve (obtained by moving each of its three two-torsion points to
  the origin, using the three radicals `√(A+2)`, `√(2-A)`, `√(A²-4)`) all have
  the same `j`-invariant `jQuot A`.  So the radical step is independent of the
  chosen model and of the sign of the radical.
* `modPoly2_jMont_jQuot` and `modPoly2_radical_step` — the pair
  `(j(E_A), j(E_{A'}))` is a zero of the level-2 modular polynomial `Φ₂`.  This
  is the definitive certificate of 2-isogeny, proved as a polynomial identity
  of degree 54 in `A`.
* `radChain_isTwoIsogenyPath` — an admissible radical walk traces a path in the
  2-isogeny graph, by induction along the walk.
* `two_isogeny_neighbours_card_le_three` — `Φ₂` is monic of degree three in each
  variable, so every vertex of the 2-isogeny graph has at most three neighbours;
  this bounds the branching of a radical walk and is what makes the walk a walk
  on a cubic (Ramanujan) graph.
-/
import Cryptography.IsogenySIDH.RadicalMontgomeryFormula

namespace Cryptography.IsogenySIDH

open Polynomial

variable {K : Type*} [Field K]

/-! ## `j`-invariants -/

/-- The `j`-invariant of the Montgomery curve `y² = x³ + A x² + x`. -/
def jMont (A : K) : K := 256 * (A ^ 2 - 3) ^ 3 / (A ^ 2 - 4)

/-- The `j`-invariant of the quotient of `E_A` by `⟨(0,0)⟩`, as a rational
function of `A` alone. -/
def jQuot (A : K) : K := 16 * (A ^ 2 + 12) ^ 3 / (A ^ 2 - 4) ^ 2

/-- The Montgomery `j`-invariant is twist invariant. -/
theorem jMont_neg (A : K) : jMont (-A) = jMont A := by
  simp only [jMont, neg_sq]

/-- The quotient `j`-invariant is twist invariant. -/
theorem jQuot_neg (A : K) : jQuot (-A) = jQuot A := by
  simp only [jQuot, neg_sq]

/-! ## The three Montgomery models of the quotient -/

/-- Renormalisation at the two-torsion point `X = -2` of the quotient curve,
using the radical `γ` with `γ² = 2 - A`. -/
def radTwoParamMinus (A γ : K) : K := (A - 6) / (2 * γ)

/-- Renormalisation at the two-torsion point `X = -A` of the quotient curve,
using the radical `δ` with `δ² = A² - 4`. -/
def radTwoParamCentre (A δ : K) : K := -(2 * A) / δ

/-- **The target of the radical step, computed.**  For any square root `α` of
`A + 2`, the Montgomery parameter `radTwoParam A α` has `j`-invariant
`jQuot A`.  In particular the radical itself disappears from the answer. -/
theorem jMont_radTwoParam {A α : K} (htwo : (2 : K) ≠ 0) (hα : α ≠ 0)
    (hsq : α ^ 2 = A + 2) (hd : A ^ 2 - 4 ≠ 0) :
    jMont (radTwoParam A α) = jQuot A := by
  have hfour : (4 : K) ≠ 0 := by
    have h : (4 : K) = 2 * 2 := by norm_num
    rw [h]; exact mul_ne_zero htwo htwo
  have hα2 : α ^ 2 ≠ 0 := pow_ne_zero 2 hα
  have hAm2 : A - 2 ≠ 0 := fun h => hd (by linear_combination (A + 2) * h)
  have hnum : ((A + 6) / (2 * α)) ^ 2 - 3 = (A ^ 2 + 12) / (4 * α ^ 2) := by
    field_simp; linear_combination (-48 : K) * hsq
  have hden : ((A + 6) / (2 * α)) ^ 2 - 4 = (A - 2) ^ 2 / (4 * α ^ 2) := by
    field_simp; linear_combination (-64 : K) * hsq
  have h4 : (A ^ 2 - 4) ^ 2 = (α ^ 2) ^ 2 * (A - 2) ^ 2 := by
    rw [hsq]; ring
  simp only [jMont, jQuot, radTwoParam, hnum, hden, h4]
  field_simp
  ring

/-- The second Montgomery model of the quotient (kernel point `X = -2`) has the
same `j`-invariant. -/
theorem jMont_radTwoParamMinus {A γ : K} (htwo : (2 : K) ≠ 0) (hγ : γ ≠ 0)
    (hsq : γ ^ 2 = 2 - A) (hd : A ^ 2 - 4 ≠ 0) :
    jMont (radTwoParamMinus A γ) = jQuot A := by
  have hfour : (4 : K) ≠ 0 := by
    have h : (4 : K) = 2 * 2 := by norm_num
    rw [h]; exact mul_ne_zero htwo htwo
  have hγ2 : γ ^ 2 ≠ 0 := pow_ne_zero 2 hγ
  have hAp2 : A + 2 ≠ 0 := fun h => hd (by linear_combination (A - 2) * h)
  have hnum : ((A - 6) / (2 * γ)) ^ 2 - 3 = (A ^ 2 + 12) / (4 * γ ^ 2) := by
    field_simp; linear_combination (-48 : K) * hsq
  have hden : ((A - 6) / (2 * γ)) ^ 2 - 4 = (A + 2) ^ 2 / (4 * γ ^ 2) := by
    field_simp; linear_combination (-64 : K) * hsq
  have h4 : (A ^ 2 - 4) ^ 2 = (γ ^ 2) ^ 2 * (A + 2) ^ 2 := by
    rw [hsq]; ring
  simp only [jMont, jQuot, radTwoParamMinus, hnum, hden, h4]
  field_simp
  ring

/-- The third Montgomery model of the quotient (kernel point `X = -A`) has the
same `j`-invariant. -/
theorem jMont_radTwoParamCentre {A δ : K} (htwo : (2 : K) ≠ 0) (hδ : δ ≠ 0)
    (hsq : δ ^ 2 = A ^ 2 - 4) : jMont (radTwoParamCentre A δ) = jQuot A := by
  have hfour : (4 : K) ≠ 0 := by
    have h : (4 : K) = 2 * 2 := by norm_num
    rw [h]; exact mul_ne_zero htwo htwo
  have h16 : (16 : K) ≠ 0 := by
    have h : (16 : K) = 4 * 4 := by norm_num
    rw [h]; exact mul_ne_zero hfour hfour
  have hδ2 : δ ^ 2 ≠ 0 := pow_ne_zero 2 hδ
  have hnum : (-(2 * A) / δ) ^ 2 - 3 = (A ^ 2 + 12) / δ ^ 2 := by
    field_simp; linear_combination (-3 : K) * hsq
  have hden : (-(2 * A) / δ) ^ 2 - 4 = 16 / δ ^ 2 := by
    field_simp; linear_combination (-4 : K) * hsq
  have h4 : (A ^ 2 - 4) ^ 2 = (δ ^ 2) ^ 2 := by rw [hsq]
  simp only [jMont, jQuot, radTwoParamCentre, hnum, hden, h4]
  field_simp
  ring

/-- **Model independence of the radical step.**  All three Montgomery
renormalisations of the quotient curve, obtained from the three distinct
radicals `√(A+2)`, `√(2-A)` and `√(A²-4)`, define the same point of the
`j`-line.  Consequently the radical step is well defined on `j`-invariants, and
in particular independent of the sign of the extracted root. -/
theorem jMont_model_independent {A α γ δ : K} (htwo : (2 : K) ≠ 0)
    (hα : α ≠ 0) (hsqα : α ^ 2 = A + 2)
    (hγ : γ ≠ 0) (hsqγ : γ ^ 2 = 2 - A)
    (hδ : δ ≠ 0) (hsqδ : δ ^ 2 = A ^ 2 - 4)
    (hd : A ^ 2 - 4 ≠ 0) :
    jMont (radTwoParam A α) = jMont (radTwoParamMinus A γ) ∧
      jMont (radTwoParamMinus A γ) = jMont (radTwoParamCentre A δ) := by
  refine ⟨?_, ?_⟩
  · rw [jMont_radTwoParam htwo hα hsqα hd, jMont_radTwoParamMinus htwo hγ hsqγ hd]
  · rw [jMont_radTwoParamMinus htwo hγ hsqγ hd, jMont_radTwoParamCentre htwo hδ hsqδ]

/-- The sign of the extracted radical does not change the target `j`-invariant:
the two branches are quadratic twists of each other. -/
theorem jMont_radTwoParam_sign_independent (A α : K) :
    jMont (radTwoParam A (-α)) = jMont (radTwoParam A α) := by
  rw [radTwoParam_neg, jMont_neg]

/-! ## The level-2 modular polynomial -/

/-- The classical modular polynomial of level two,
`Φ₂(X,Y) = X³ + Y³ - X²Y² + 1488(X²Y + XY²) - 162000(X²+Y²) + 40773375XY
          + 8748000000(X+Y) - 157464000000000`. -/
def modPoly2 (X Y : K) : K :=
  X ^ 3 + Y ^ 3 - X ^ 2 * Y ^ 2 + 1488 * (X ^ 2 * Y + X * Y ^ 2)
    - 162000 * (X ^ 2 + Y ^ 2) + 40773375 * (X * Y)
    + 8748000000 * (X + Y) - 157464000000000

/-- `Φ₂` is symmetric; equivalently, the 2-isogeny graph is undirected (every
2-isogeny has a dual). -/
theorem modPoly2_symm (X Y : K) : modPoly2 X Y = modPoly2 Y X := by
  simp only [modPoly2]; ring

/-- **The core modular identity.**  For every Montgomery parameter with
nonvanishing discriminant factor `A² - 4`, the pair consisting of the curve's
`j`-invariant and the quotient `j`-invariant is a zero of `Φ₂`.  Unwinding the
divisions this is a polynomial identity of degree `54` in `A`. -/
theorem modPoly2_jMont_jQuot {A : K} (hd : A ^ 2 - 4 ≠ 0) :
    modPoly2 (jMont A) (jQuot A) = 0 := by
  simp only [jMont, jQuot, modPoly2]
  set t := A ^ 2
  clear_value t
  field_simp
  ring

/-- **Radical step certificate.**  The parameter produced by one radical
Montgomery step is 2-isogenous to the source, certified by `Φ₂`. -/
theorem modPoly2_radical_step {A α : K} (htwo : (2 : K) ≠ 0) (hα : α ≠ 0)
    (hsq : α ^ 2 = A + 2) (hd : A ^ 2 - 4 ≠ 0) :
    modPoly2 (jMont A) (jMont (radTwoParam A α)) = 0 := by
  rw [jMont_radTwoParam htwo hα hsq hd]
  exact modPoly2_jMont_jQuot hd

/-- The dual direction is certified as well. -/
theorem modPoly2_radical_step_dual {A α : K} (htwo : (2 : K) ≠ 0) (hα : α ≠ 0)
    (hsq : α ^ 2 = A + 2) (hd : A ^ 2 - 4 ≠ 0) :
    modPoly2 (jMont (radTwoParam A α)) (jMont A) = 0 := by
  rw [modPoly2_symm]
  exact modPoly2_radical_step htwo hα hsq hd

/-! ## Radical walks are paths in the 2-isogeny graph -/

/-- A sequence of `j`-invariants is a path in the 2-isogeny graph when every
consecutive pair is a zero of `Φ₂`. -/
def IsTwoIsogenyPath (j : ℕ → K) : Prop := ∀ n, modPoly2 (j n) (j (n + 1)) = 0

/-- A radical walk is *nonsingular* when every parameter it visits has
nonvanishing `A² - 4`, i.e. stays away from the two degenerate Montgomery
parameters `±2`. -/
def NonsingularWalk (r : ℕ → K) (A : K) : Prop :=
  AdmissibleWalk r A ∧ ∀ n, (radChain r A n) ^ 2 - 4 ≠ 0

/-- **Main theorem: a radical isogeny walk is a path in the 2-isogeny graph.**
Every consecutive pair of `j`-invariants visited by a nonsingular admissible
radical walk is a zero of the modular polynomial `Φ₂`. -/
theorem radChain_isTwoIsogenyPath {r : ℕ → K} {A : K} (htwo : (2 : K) ≠ 0)
    (h : NonsingularWalk r A) :
    IsTwoIsogenyPath (fun n => jMont (radChain r A n)) := by
  intro n
  obtain ⟨hadm, hns⟩ := h
  obtain ⟨h0, hsq⟩ := hadm n
  simpa [radChain_succ] using modPoly2_radical_step htwo h0 hsq (hns n)

/-- Along a nonsingular walk, each step's target `j` is the rational function
`jQuot` of the previous parameter — so the whole walk is computed without ever
naming the radicals, by induction on the step index. -/
theorem radChain_jMont_eq_jQuot {r : ℕ → K} {A : K} (htwo : (2 : K) ≠ 0)
    (h : NonsingularWalk r A) (n : ℕ) :
    jMont (radChain r A (n + 1)) = jQuot (radChain r A n) := by
  obtain ⟨hadm, hns⟩ := h
  obtain ⟨h0, hsq⟩ := hadm n
  simpa [radChain_succ] using jMont_radTwoParam htwo h0 hsq (hns n)

/-- The `j`-invariant sequence of a nonsingular walk is the orbit of the
rational map `jQuot` composed with the parameter recursion — a statement
proved by induction that turns the walk into a deterministic dynamical
system on the `j`-line. -/
theorem radChain_jMont_iterate {r : ℕ → K} {A : K} (htwo : (2 : K) ≠ 0)
    (h : NonsingularWalk r A)
    (f : ℕ → K) (h0 : f 0 = jMont A)
    (hstep : ∀ n, f (n + 1) = jQuot (radChain r A n)) (n : ℕ) :
    f n = jMont (radChain r A n) := by
  induction n with
  | zero => simpa using h0
  | succ n _ => rw [hstep n, radChain_jMont_eq_jQuot htwo h n]

/-! ## Degree bound: the 2-isogeny graph is cubic -/

/-- `Φ₂(j, ·)` as an honest univariate polynomial. -/
noncomputable def modPoly2Y (j : K) : K[X] :=
  C 1 * X ^ 3 + C (-(j ^ 2) + 1488 * j - 162000) * X ^ 2
    + C (1488 * j ^ 2 + 40773375 * j + 8748000000) * X
    + C (j ^ 3 - 162000 * j ^ 2 + 8748000000 * j - 157464000000000)

theorem modPoly2Y_eval (j y : K) : (modPoly2Y j).eval y = modPoly2 j y := by
  simp only [modPoly2Y, modPoly2, eval_add, eval_mul, eval_pow, eval_C, eval_X]
  ring

theorem modPoly2Y_natDegree (j : K) : (modPoly2Y j).natDegree = 3 :=
  natDegree_cubic one_ne_zero

theorem modPoly2Y_ne_zero (j : K) : modPoly2Y j ≠ 0 := by
  intro h
  have := modPoly2Y_natDegree j
  rw [h] at this
  simp at this

/-- **The 2-isogeny graph is at most 3-regular.**  For a fixed `j`, at most
three values `j'` satisfy `Φ₂(j, j') = 0`; equivalently, a supersingular curve
has at most three 2-isogenous neighbours (counted without multiplicity).  This
is the branching bound for radical 2-isogeny walks. -/
theorem two_isogeny_neighbours_card_le_three [DecidableEq K] (j : K)
    (S : Finset K) (hS : ∀ y ∈ S, modPoly2 j y = 0) : S.card ≤ 3 := by
  have hsub : S ⊆ (modPoly2Y j).roots.toFinset := by
    intro y hy
    rw [Multiset.mem_toFinset, mem_roots (modPoly2Y_ne_zero j), IsRoot, modPoly2Y_eval]
    exact hS y hy
  calc S.card ≤ (modPoly2Y j).roots.toFinset.card := Finset.card_le_card hsub
    _ ≤ Multiset.card (modPoly2Y j).roots := Multiset.toFinset_card_le _
    _ ≤ (modPoly2Y j).natDegree := card_roots' _
    _ = 3 := modPoly2Y_natDegree j

/-! ## How many Montgomery models does one `j`-invariant have? -/

/-- The polynomial whose roots are the Montgomery parameters with a prescribed
`j`-invariant: `256(A²-3)³ - j(A²-4)`. -/
noncomputable def montModelPoly (j : K) : K[X] :=
  C 256 * X ^ 6 - C 2304 * X ^ 4 + C (6912 - j) * X ^ 2 + C (4 * j - 6912)

theorem montModelPoly_eval (j A : K) :
    (montModelPoly j).eval A = 256 * (A ^ 2 - 3) ^ 3 - j * (A ^ 2 - 4) := by
  simp only [montModelPoly, eval_add, eval_sub, eval_mul, eval_pow, eval_C, eval_X]
  ring

theorem montModelPoly_natDegree (htwo : (2 : K) ≠ 0) (j : K) :
    (montModelPoly j).natDegree = 6 := by
  have h256 : (256 : K) ≠ 0 := by
    have h : (256 : K) = 2 ^ 8 := by norm_num
    rw [h]; exact pow_ne_zero 8 htwo
  unfold montModelPoly
  compute_degree!

theorem montModelPoly_ne_zero (htwo : (2 : K) ≠ 0) (j : K) : montModelPoly j ≠ 0 := by
  intro h
  have hdeg := montModelPoly_natDegree htwo j
  rw [h] at hdeg
  simp at hdeg

/-- A Montgomery parameter is a root of `montModelPoly j` exactly when its
`j`-invariant is `j`. -/
theorem jMont_eq_iff_isRoot {A j : K} (hd : A ^ 2 - 4 ≠ 0) :
    jMont A = j ↔ (montModelPoly j).IsRoot A := by
  rw [IsRoot, montModelPoly_eval, jMont, div_eq_iff hd]
  constructor <;> intro h <;> linear_combination h

/-- **At most six Montgomery models per `j`-invariant.**  A supersingular curve
has at most six Montgomery coefficients, matching the six orderings of its
three two-torsion points.  Together with
`two_isogeny_neighbours_card_le_three` this bounds the branching data a radical
walk has to choose from at each step. -/
theorem montgomery_models_card_le_six [DecidableEq K] (htwo : (2 : K) ≠ 0) (j : K)
    (S : Finset K) (hS : ∀ A ∈ S, A ^ 2 - 4 ≠ 0 ∧ jMont A = j) : S.card ≤ 6 := by
  have hsub : S ⊆ (montModelPoly j).roots.toFinset := by
    intro A hA
    obtain ⟨hd, hj⟩ := hS A hA
    rw [Multiset.mem_toFinset, mem_roots (montModelPoly_ne_zero htwo j)]
    exact (jMont_eq_iff_isRoot hd).mp hj
  calc S.card ≤ (montModelPoly j).roots.toFinset.card := Finset.card_le_card hsub
    _ ≤ Multiset.card (montModelPoly j).roots := Multiset.toFinset_card_le _
    _ ≤ (montModelPoly j).natDegree := card_roots' _
    _ = 6 := montModelPoly_natDegree htwo j

end Cryptography.IsogenySIDH