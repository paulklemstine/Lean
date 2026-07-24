import Mathlib
import Algebra.SnCharacterTable.ConjClassCount

/-!
# Products of normalized McKay--Thompson type series

A finite family of normalized Laurent polynomials is used as an exact algebraic
model for finite truncations of McKay--Thompson series.  The main results separate
three logically distinct claims that are often conflated in informal accounts of
moonshine:

* multiplying normalized series adds their principal exponents;
* invariance of all factors forces invariance of their product;
* character multiplicities are recoverable from coefficient functions only when
  the chosen character-evaluation map is injective.

The second point gives a sharp obstruction to assigning a nonzero modular weight
to a product of weight-zero modular functions without adding a compensating
factor.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Six falsifiable proposals were ranked by impact.
(1) A classwise product alone has a positive modular weight determined by the
finite group order. (2) Its principal exponent is minus the number of indexed
classes. (3) Weight-zero transformation laws survive finite products. (4) The
coefficient functions determine all graded multiplicities whenever the character
map is injective. (5) The same reconstruction survives a noninjective character
map. (6) A compensating series can change the transformation weight while adding
its principal exponent. Proposals (1), (4), and (6) are the broadest bridges among
finite-group character theory, graded representation data, and modular behavior.

Experiment (Experimenter): Normalized series were represented as `T⁻¹` times a
regular Laurent polynomial with constant coefficient one. Induction over a finite
index set proves the exact product factorization. Transformation laws were tested
pointwise, and coefficient reconstruction was reduced to injectivity. The imported
symmetric-group class count supplies concrete finite conjugacy-class examples.

Analysis (Analyst): Proposals (2), (3), (4), and (6) survive in the precise forms
below. Proposal (1) fails without a compensator: a product of invariant functions
is invariant, and at any nonzero value it cannot also acquire a nontrivial
factor of automorphy. Proposal (5) is false: two different multiplicity vectors in
one fiber of a noninjective evaluation map have identical coefficient data. The
unifying pattern is that products aggregate additive grading data, whereas
recoverability is controlled by injectivity, not by multiplication itself.

Critique (Critic): No theorem assumes that the Monster or its 194 classes have
already been constructed. The algebraic results apply to every finite class index.
The phrase “product over all g” has an important boundary: indexing group elements
and indexing conjugacy classes generally gives different pole exponents. Nor does
a finite Laurent model establish analytic convergence or genus-zero modularity.
The nonzero hypothesis in the weight obstruction is essential; at a zero, two
transformation laws provide no contradiction.

Synthesis (Principal Investigator): The verified core is a product-normalization
theorem, a weight-zero closure theorem with a nonzero-point obstruction, a
compensator theorem, and an exact injectivity criterion for character recovery.
A broader extension should replace Laurent polynomials by convergent meromorphic
q-series and instantiate the abstract character map with the full complex
character table.
-- !-- End Lab Notes -- !--
-/

open scoped BigOperators

namespace MoonshineProduct

noncomputable section

/-- Finite algebraic data for a family of normalized series.  The associated
series has one prescribed `q⁻¹` factor; `regularConstant` rules out a zero regular
factor and records the usual normalization. -/
structure NormalizedFamily (C R : Type*) [CommSemiring R] where
  regular : C → LaurentPolynomial R
  regularConstant : ∀ c, regular c 0 = 1

/-- The normalized series attached to an index. -/
def NormalizedFamily.series {C R : Type*} [CommSemiring R]
    (D : NormalizedFamily C R) (c : C) : LaurentPolynomial R :=
  LaurentPolynomial.T (-1) * D.regular c

/-- A finite product of normalized series has exactly one displayed `q⁻¹` factor
per index.  Thus its aggregate principal exponent is the negative cardinality of
the indexing set. -/
theorem normalized_product_factorization {C R : Type*} [CommSemiring R]
    (D : NormalizedFamily C R) (s : Finset C) :
    ∏ c ∈ s, D.series c =
      LaurentPolynomial.T (-(s.card : ℤ)) * ∏ c ∈ s, D.regular c := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | @insert a s ha ih =>
    rw [Finset.prod_insert ha, Finset.prod_insert ha, ih]
    unfold NormalizedFamily.series
    rw [mul_mul_mul_comm]
    rw [← LaurentPolynomial.T_add]
    congr 2
    simp [Finset.card_insert_of_notMem ha]

/-- Every regular factor in normalized data is nonzero. -/
lemma regular_ne_zero {C R : Type*} [CommSemiring R] [Nontrivial R]
    (D : NormalizedFamily C R) (c : C) : D.regular c ≠ 0 := by
  intro h
  have h0 := congrArg (fun f : LaurentPolynomial R => f 0) h
  simp [D.regularConstant c] at h0

/-- Over a domain, a finite product of normalized series cannot vanish. -/
theorem normalized_product_ne_zero {C R : Type*} [CommRing R] [IsDomain R]
    (D : NormalizedFamily C R) (s : Finset C) :
    ∏ c ∈ s, D.series c ≠ 0 := by
  classical
  rw [normalized_product_factorization]
  apply mul_ne_zero
  · intro h
    have h_at := congrArg (fun f : LaurentPolynomial R => f (-(s.card : ℤ))) h
    simp at h_at
  · exact Finset.prod_ne_zero_iff.mpr (fun c _ => regular_ne_zero D c)

/-- Pointwise invariance under a transformation. -/
def InvariantUnder {X R : Type*} (γ : X → X) (f : X → R) : Prop :=
  ∀ x, f (γ x) = f x

/-- A finite product of invariant functions remains invariant.  This is the
weight-zero closure law for classwise products of modular functions. -/
theorem finite_product_invariant {C X R : Type*} [CommMonoid R]
    (γ : X → X) (s : Finset C) (F : C → X → R)
    (hF : ∀ c ∈ s, InvariantUnder γ (F c)) :
    InvariantUnder γ (fun x => ∏ c ∈ s, F c x) := by
  classical
  intro x
  apply Finset.prod_congr rfl
  intro c hc
  exact hF c hc x

/-- **Weight obstruction.** If an invariant product is also claimed to transform
by a factor `J`, then at every point where the product is nonzero that factor must
be one. -/
theorem invariant_and_weighted_forces_factor_one {X K : Type*} [Field K]
    (γ : X → X) (P J : X → K)
    (hInv : InvariantUnder γ P)
    (hWeighted : ∀ x, P (γ x) = J x * P x)
    {x : X} (hPx : P x ≠ 0) : J x = 1 := by
  have h := (hWeighted x).symm.trans (hInv x)
  apply (mul_right_cancel₀ hPx)
  simpa using h

/-- Multiplication by a compensator transfers its transformation factor to an
otherwise invariant product. -/
theorem compensator_changes_weight {X R : Type*} [CommMonoid R]
    (γ : X → X) (P A J : X → R)
    (hP : InvariantUnder γ P)
    (hA : ∀ x, A (γ x) = J x * A x) :
    ∀ x, (A (γ x) * P (γ x)) = J x * (A x * P x) := by
  intro x
  rw [hA x, hP x]
  exact mul_assoc _ _ _

/-- An abstract character-evaluation map.  Injectivity is precisely the condition
needed for coefficient functions to recover multiplicity vectors. -/
structure CharacterEncoding (Rep Class R : Type*) where
  evaluate : (Rep → R) → (Class → R)

/-- Equality of all coefficient functions recovers multiplicities when character
evaluation is injective. -/
theorem recover_multiplicities_of_injective {Rep Class R : Type*}
    (E : CharacterEncoding Rep Class R) (hE : Function.Injective E.evaluate)
    (m₁ m₂ : ℕ → Rep → R)
    (hcoeff : ∀ n c, E.evaluate (m₁ n) c = E.evaluate (m₂ n) c) :
    m₁ = m₂ := by
  funext n
  apply hE
  funext c
  exact hcoeff n c

/-- The injectivity boundary is exact: a collision in character evaluation gives
two distinct graded multiplicity assignments with identical coefficient data. -/
theorem collision_produces_indistinguishable_gradings {Rep Class R : Type*}
    (E : CharacterEncoding Rep Class R) (u v : Rep → R)
    (huv : u ≠ v) (hcollision : E.evaluate u = E.evaluate v) :
    ∃ m₁ m₂ : ℕ → Rep → R,
      m₁ ≠ m₂ ∧ ∀ n, E.evaluate (m₁ n) = E.evaluate (m₂ n) := by
  refine ⟨fun _ => u, fun _ => v, ?_, ?_⟩
  · intro h
    have h0 := congrFun h 0
    exact huv h0
  · intro n
    exact hcollision

/-! ## Concrete examples -/

/-- A concrete three-index normalized family. -/
def threeSeries : NormalizedFamily (Fin 3) ℤ where
  regular _ := LaurentPolynomial.T 0
  regularConstant := by
    intro c
    exact LaurentPolynomial.T_apply 0 0

/-- The three-series product displays the aggregate factor `q⁻³`. -/
example :
    ∏ c : Fin 3, threeSeries.series c =
      LaurentPolynomial.T (-3) * ∏ c : Fin 3, threeSeries.regular c := by
  simpa using normalized_product_factorization threeSeries Finset.univ

/-- The imported catalog result supplies a genuine conjugacy-class index with
three elements: the classes of `S₃`. -/
example : Fintype.card (ConjClasses (Equiv.Perm (Fin 3))) = 3 := by
  exact SnConjClassCount.card_conjClasses_S3

/-- For `S₃`-indexed normalized data, the displayed product exponent is `-3`. -/
example (D : NormalizedFamily (ConjClasses (Equiv.Perm (Fin 3))) ℤ) :
    ∏ c, D.series c = LaurentPolynomial.T (-3) * ∏ c, D.regular c := by
  rw [normalized_product_factorization]
  rw [Finset.card_univ, SnConjClassCount.card_conjClasses_S3]
  norm_num

end

end MoonshineProduct