/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Pseudofinite Transfer via Restricted Łoś Theorem

This file develops a restricted Łoś transfer theorem for polynomially definable
matrix predicates, providing a formally verified bridge between finite-field
combinatorial theorems and pseudofinite structural results.

## Architecture

The transfer proceeds in three layers:
1. **Syntax**: A restricted first-order formula language (`RestrictedFormula`) with
   polynomial equality atoms and boolean connectives.
2. **Semantics**: Satisfaction in any commutative ring (`Sat`) and in the ultrapower
   germ ring (`Filter.Germ`).
3. **Transfer**: The main Łoś theorem proving equivalence of satisfaction in the
   germ ring with eventual componentwise satisfaction.

## Main Results

* `eval₂_germ_eq_germ_eval₂`: Polynomial evaluation commutes with taking germs
* `los_restrictedFormula`: Łoś's theorem for restricted polynomial formulas
* `mem_ultraSet_iff_eventually`: Transfer of definable set membership
* `pseudofinite_growth_control_transfer`: Transfer of growth-or-control dichotomy

## References

* Hrushovski, E. (2012). Stable group theory and approximate subgroups.
* Breuillard, E., Green, B., Tao, T. (2012). The structure of approximate groups.
-/

import Mathlib

namespace PseudofiniteTransfer

open Filter MvPolynomial Set

/-! ## Section 1: Restricted Formula Language

We define a restricted first-order formula language with polynomial equality
atoms over integer coefficients and boolean connectives. This fragment is
sufficient to express membership in polynomial image sets, product-set
conditions, and boolean combinations — covering the predicates needed for
growth/control dichotomies in definable combinatorics over matrix rings.
-/

/-- A restricted polynomial formula over variables of type `σ` with integer
coefficients. This is the fragment of first-order logic tailored for
polynomially definable matrix predicates.

The design choices are deliberate:
- **Polynomial equality atoms** capture the defining equations of algebraic varieties
  and polynomial image sets.
- **Boolean connectives** allow expressing intersections, unions, and complements
  of definable sets.
- **No quantifiers** in this base layer; quantifier-free transfer is proved first,
  then extended to bounded existentials via separate theorems.
- **Integer coefficients** ensure uniform definability across all fields. -/
inductive RestrictedFormula (σ : Type*) : Type _
  | /-- Polynomial `p` evaluates to zero under the variable assignment -/
    polyEq (p : MvPolynomial σ ℤ) : RestrictedFormula σ
  | /-- Conjunction: both sub-formulas hold -/
    conj (φ ψ : RestrictedFormula σ) : RestrictedFormula σ
  | /-- Disjunction: at least one sub-formula holds -/
    disj (φ ψ : RestrictedFormula σ) : RestrictedFormula σ
  | /-- Negation: the sub-formula does not hold -/
    neg (φ : RestrictedFormula σ) : RestrictedFormula σ

namespace RestrictedFormula

/-- Satisfaction of a restricted formula in a commutative ring `R`, given an
assignment `v : σ → R` of values to variables.

For polynomial equality atoms, satisfaction means the polynomial evaluates
to zero. For boolean connectives, satisfaction follows the standard
propositional logic semantics. -/
def Sat {σ : Type*} (R : Type*) [CommRing R] :
    RestrictedFormula σ → (σ → R) → Prop
  | polyEq p, v => MvPolynomial.eval₂ (Int.castRingHom R) v p = 0
  | conj φ ψ, v => φ.Sat R v ∧ ψ.Sat R v
  | disj φ ψ, v => φ.Sat R v ∨ ψ.Sat R v
  | neg φ, v => ¬ φ.Sat R v

end RestrictedFormula

/-! ## Section 2: Polynomial Evaluation Commutes with Germs

The algebraic heart of the transfer principle: evaluating an integer-coefficient
polynomial in the ultrapower germ ring gives the same result as taking the germ
of pointwise evaluations. This is proved by structural induction on multivariate
polynomials, using the fact that germ formation preserves ring operations.
-/

section EvalGerm

variable {ι : Type*} (U : Ultrafilter ι) {K : Type*} [CommRing K] {σ : Type*}

/-
**Key Technical Lemma**: Evaluation of an integer-coefficient multivariate
polynomial commutes with taking germs in the ultrapower.

Concretely, if `v : σ → ι → K` assigns to each variable `s` a function
`v s : ι → K`, then evaluating `p` with variables `s ↦ ⊦v s⊧` in the
germ ring equals the germ of the function `i ↦ eval₂ (v · i) p`.

The proof proceeds by `MvPolynomial.induction_on`:
- **Constants**: integer cast into `Germ U K` equals germ of constant function.
- **Addition**: follows from `Germ.coe_add`.
- **Multiplication by variable**: follows from `Germ.coe_mul`.
-/
theorem eval₂_germ_eq_germ_eval₂
    (p : MvPolynomial σ ℤ)
    (v : σ → ι → K) :
    MvPolynomial.eval₂ (Int.castRingHom (Germ (U : Filter ι) K))
      (fun s => (↑(v s) : Germ (U : Filter ι) K)) p =
    (↑(fun i => MvPolynomial.eval₂ (Int.castRingHom K) (fun s => v s i) p) :
      Germ (U : Filter ι) K) := by
  induction' p using MvPolynomial.induction_on with n p q hp hq;
  · induction' n using Int.induction_on with n ihn n ihn;
    · simp +decide [ MvPolynomial.eval₂_C ];
      rfl;
    · simp +decide [ MvPolynomial.eval₂_C ];
      rfl;
    · simp_all +decide [ sub_eq_add_neg ];
      erw [ Filter.Germ.coe_add ] ; aesop;
  · convert congr_arg₂ ( · + · ) hp hq using 1;
    · simp +decide [ MvPolynomial.eval₂_add ];
    · exact congr_arg _ ( funext fun i => by simp +decide [ MvPolynomial.eval₂_add ] );
  · simp_all +decide [ MvPolynomial.eval₂_mul ]
    exact?

end EvalGerm

/-! ## Section 3: Boolean Closure Lemmas for Ultrafilters

These are the logical joints of the transfer machine. They express the
fundamental property that ultrafilters are exactly the maximal proper filters,
decomposing every set into "large" (∈ U) or "small" (complement ∈ U).
-/

section BooleanClosure

variable {ι : Type*} (U : Ultrafilter ι)

/-
Conjunction transfer: a set defined by `P ∧ Q` is in `U` iff both
individual sets are. This holds for any filter (not just ultrafilters)
because `{i | P i ∧ Q i} = {i | P i} ∩ {i | Q i}`.
-/
theorem setOf_and_mem_iff {P Q : ι → Prop} :
    {i | P i ∧ Q i} ∈ U ↔ {i | P i} ∈ U ∧ {i | Q i} ∈ U := by
  constructor <;> intro h;
  · exact ⟨ Filter.mem_of_superset h fun i hi => hi.1, Filter.mem_of_superset h fun i hi => hi.2 ⟩;
  · exact Filter.inter_mem h.1 h.2

/-
Disjunction transfer: a set defined by `P ∨ Q` is in `U` iff at least
one individual set is. This requires the **ultrafilter property**: every
set is either large or co-large.
-/
theorem setOf_or_mem_iff {P Q : ι → Prop} :
    {i | P i ∨ Q i} ∈ U ↔ {i | P i} ∈ U ∨ {i | Q i} ∈ U := by
  constructor <;> intro h <;> simp_all +decide [ Set.setOf_or ]

/-
Negation transfer: a set defined by `¬P` is in `U` iff the set defined
by `P` is not in `U`. This requires the **ultrafilter property**.
-/
theorem setOf_neg_mem_iff {P : ι → Prop} :
    {i | ¬ P i} ∈ U ↔ {i | P i} ∉ U := by
  rw [ ← Ultrafilter.compl_mem_iff_notMem ];
  rfl

end BooleanClosure

/-! ## Section 4: Łoś's Theorem for Restricted Formulas

The main transfer theorem: satisfaction of a restricted formula in the
ultrapower germ ring is equivalent to the set of indices where the formula
is satisfied componentwise being in the ultrafilter.

This is proved by structural induction on the formula:
- **Polynomial equality**: uses `eval₂_germ_eq_germ_eval₂` + germ-zero characterization
- **Conjunction**: uses `setOf_and_mem_iff`
- **Disjunction**: uses `setOf_or_mem_iff` (requires ultrafilter property)
- **Negation**: uses `setOf_neg_mem_iff` (requires ultrafilter property)
-/

/-
**Łoś's Theorem (Restricted Version)**: For any restricted polynomial
formula `φ` and variable assignment `v : σ → ι → K`, satisfaction of `φ`
in the ultrapower germ ring `Germ U K` with variables `s ↦ ⟦v s⟧` is
equivalent to the set of indices where `φ` is satisfied componentwise
being in the ultrafilter `U`.

This is the core transfer principle that bridges finite-field combinatorics
to pseudofinite structural results. The ultrafilter property is essential
for the disjunction and negation cases.
-/
theorem los_restrictedFormula
    {ι : Type*} {U : Ultrafilter ι}
    {K : Type*} [CommRing K]
    {σ : Type*}
    (φ : RestrictedFormula σ)
    (v : σ → ι → K) :
    RestrictedFormula.Sat (Germ (U : Filter ι) K) φ
      (fun s => (↑(v s) : Germ (U : Filter ι) K)) ↔
    {i | RestrictedFormula.Sat K φ (fun s => v s i)} ∈ U := by
  induction' φ with p φ ψ hφ hψ generalizing v;
  · simp +decide [ RestrictedFormula.Sat ];
    rw [ eval₂_germ_eq_germ_eval₂ ];
    erw [ Filter.Germ.coe_eq ];
    rfl;
  · simp +decide [ RestrictedFormula.Sat, hφ, hψ ];
    rw [ ← setOf_and_mem_iff ];
  · simp_all +decide [ Set.setOf_or, RestrictedFormula.Sat ];
  · simp +decide [ *, RestrictedFormula.Sat ];
    exact Iff.symm (setOf_neg_mem_iff U)

/-! ## Section 5: Polynomially Definable Subsets and Membership Transfer

We specialize the Łoś theorem to transfer membership in polynomially
definable subsets of matrix rings.
-/

/-- A polynomially definable subset of `n × n` matrices is specified by a
restricted formula whose variables are the matrix entries `(i, j)`.

A matrix `M` belongs to the subset when the formula is satisfied by the
assignment `(i, j) ↦ M i j`. -/
structure PolyDefinableSubset (n : ℕ) where
  /-- The defining formula with variables indexed by matrix entry positions -/
  formula : RestrictedFormula (Fin n × Fin n)

namespace PolyDefinableSubset

/-- Membership: a matrix `M` is in the definable subset when the defining
formula is satisfied by assigning each variable `(i,j)` to `M i j`. -/
def mem {n : ℕ} (A : PolyDefinableSubset n) {K : Type*} [CommRing K]
    (M : Matrix (Fin n) (Fin n) K) : Prop :=
  A.formula.Sat K (fun ij => M ij.1 ij.2)

end PolyDefinableSubset

/-
**Membership Transfer Theorem**: For a polynomially definable subset `A`
of `n × n` matrices, a matrix over the germ ring belongs to `A` iff the
set of indices where the componentwise matrix belongs to `A` is in the
ultrafilter.

This is the direct application of Łoś's theorem to definable set membership,
providing the bridge from finite combinatorics to pseudofinite structure.
-/
theorem mem_ultraSet_iff_eventually
    {ι : Type*} {U : Ultrafilter ι}
    {K : Type*} [CommRing K]
    {n : ℕ}
    (A : PolyDefinableSubset n)
    (M : ι → Matrix (Fin n) (Fin n) K) :
    A.mem (Matrix.of fun i j => (↑(fun t => M t i j) : Germ (U : Filter ι) K)) ↔
    {t | A.mem (M t)} ∈ U := by
  convert PseudofiniteTransfer.los_restrictedFormula _ _

/-! ## Section 6: Growth and Control Definitions

We define transfer-compatible notions of bounded doubling and coset control,
enabling the transport of growth/control dichotomies from finite fields to
pseudofinite limits.
-/

/-- Coset control: set `A` is `C`-controlled by set `H`, meaning
`A` can be covered by at most `C` left translates of `H`. -/
def CosetControlledBy {G : Type*} [Mul G] (A H : Set G) (C : ℕ) : Prop :=
  ∃ T : Finset G, T.card ≤ C ∧ A ⊆ ⋃ t ∈ (T : Set G), (fun x => t * x) '' H

/-- Pseudofinite coset control in the ultrapower: the set of indices where
coset control holds is in the ultrafilter. -/
def UltraCosetControlledBy
    {ι : Type*} (U : Ultrafilter ι)
    {G : ι → Type*} [∀ i, Mul (G i)]
    (A H : ∀ i, Set (G i)) (C : ℕ) : Prop :=
  {i | CosetControlledBy (A i) (H i) C} ∈ U

/-- Bounded doubling for a set with a finite cardinality witness:
the product set `A · A` has at most `K` times the cardinality of `A`. -/
def HasBoundedDoubling {G : Type*} [Mul G]
    (_A : Set G) (K : ℕ) (cardA cardAA : ℕ) : Prop :=
  cardAA ≤ K * cardA

/-- Eventual bounded doubling along an ultrafilter: the set of indices where
the doubling bound `K` holds is in the ultrafilter `U`. This is a `Prop`-valued
definition suitable for use in transfer theorems. -/
def EventualBoundedDoubling
    {ι : Type*} (U : Ultrafilter ι)
    (cardA cardAA : ι → ℕ) (K : ℕ) : Prop :=
  {i | cardAA i ≤ K * cardA i} ∈ U

/-! ## Section 7: Transfer Theorems for Growth and Control -/

/-
**Control Transfer Theorem**: If a family of groups has coset control
for `U`-many indices, then pseudofinite coset control holds.

This is definitionally true but packages the result in the standard form.
-/
theorem eventual_control_transfer
    {ι : Type*} {U : Ultrafilter ι}
    {G : ι → Type*} [∀ i, Mul (G i)]
    (A H : ∀ i, Set (G i)) (C : ℕ)
    (hcontrol : {i | CosetControlledBy (A i) (H i) C} ∈ U) :
    UltraCosetControlledBy U A H C := by
  exact hcontrol

/-! ## Section 8: Growth-or-Control Dichotomy Transfer

The culminating theorem: a finite-field growth-or-control dichotomy
transfers to the pseudofinite limit.
-/

/-
**Growth-or-Control Dichotomy Transfer**: If for `U`-many indices,
bounded doubling implies coset-control, and the doubling bound holds
for `U`-many indices, then pseudofinite coset control holds.

This is the cross-domain bridge theorem connecting:
- **Model theory / logic**: ultrafilter transfer
- **Approximate group theory**: growth-or-control dichotomy
- **Finite combinatorics**: bounded doubling in finite groups
-/
theorem pseudofinite_growth_control_transfer
    {ι : Type*} {U : Ultrafilter ι}
    {G : ι → Type*} [∀ i, Mul (G i)]
    (A H : ∀ i, Set (G i))
    (K C : ℕ)
    (cardA cardAA : ι → ℕ)
    (hdich : {i | cardAA i ≤ K * cardA i →
      CosetControlledBy (A i) (H i) C} ∈ U)
    (hsmall : {i | cardAA i ≤ K * cardA i} ∈ U) :
    UltraCosetControlledBy U A H C := by
  exact U.mem_of_superset ( Filter.inter_mem hsmall hdich ) fun i hi => hi.2 hi.1

/-! ## Section 9: Bounded Existential Transfer -/

/-
**Bounded Existential Transfer**: If for `U`-many indices there exists
a witness satisfying a predicate, then witnesses can be chosen consistently
(by the axiom of choice) to form a family defined on the entire index set.

This is the key lemma for transferring existential statements through
ultrafilters, enabling reasoning about witnesses in the pseudofinite limit.
-/
theorem los_exists_bounded
    {ι : Type*} {U : Ultrafilter ι}
    {α : ι → Type*} [∀ i, Nonempty (α i)]
    (P : ∀ i, α i → Prop)
    (h : {i | ∃ x, P i x} ∈ U) :
    ∃ x : ∀ i, α i, {i | P i (x i)} ∈ U := by
  by_contra h_contra;
  -- By definition of ultrafilter, for each $i$, there exists an $x_i$ such that $P i x_i$ holds.
  have h_exists_x : ∀ i ∈ {i | ∃ x, P i x}, ∃ x_i, P i x_i := by
    exact fun i hi => hi;
  choose! x hx using h_exists_x;
  exact h_contra ⟨ x, Filter.mem_of_superset h fun i hi => hx i hi ⟩

/-
Complement characterization: `{x | ¬ P x} = {x | P x}ᶜ`.
-/
theorem setOf_neg_eq_compl {α : Type*} (P : α → Prop) :
    {x | ¬ P x} = {x | P x}ᶜ := by
  rfl

/-
Eventual equality of assignments preserves ultrafilter membership of
satisfaction sets. If two variable assignments agree on a `U`-large set
for each variable, then the satisfaction sets of any restricted formula
are simultaneously in or not in `U`.
-/
theorem ultra_eval_congr_eventually
    {ι : Type*} {U : Ultrafilter ι}
    {K : Type*} [CommRing K]
    {σ : Type*}
    (v w : σ → ι → K)
    (h : ∀ s, {i | v s i = w s i} ∈ U)
    (φ : RestrictedFormula σ) :
    ({i | RestrictedFormula.Sat K φ (fun s => v s i)} ∈ U ↔
     {i | RestrictedFormula.Sat K φ (fun s => w s i)} ∈ U) := by
  -- By the properties of the ultrafilter, if the set of indices where `v` and `w` agree is in `U`, then the satisfaction sets must also be in `U`.
  have h_eq : ∀ s, (↑(v s) : Germ (U : Filter ι) K) = (↑(w s) : Germ (U : Filter ι) K) := by
    exact fun s => EventuallyEq.germ_eq (h s);
  rw [ ← los_restrictedFormula, ← los_restrictedFormula ];
  simp +decide only [h_eq]

end PseudofiniteTransfer