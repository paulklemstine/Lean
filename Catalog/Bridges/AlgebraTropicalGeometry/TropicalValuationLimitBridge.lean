/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Bridge: Tropical Geometry as the Image of a Non-Archimedean Valuation

This file builds the *bridge* between classical algebraic geometry over a non-Archimedean
valued field and tropical geometry.  The central object is an additive valuation
`v : AddValuation K Γ`, which we read as the **tropicalization map**
`x ↦ v x` sending a field element to its order (a point of the tropical semiring).

## The bridge results

* `addValuation_sum_eq_of_unique_min` — the ultrametric "winner takes all" lemma: if one term
  of a finite sum has a *strictly* smaller valuation than all the others, the valuation of the
  sum equals that of the smallest term.  This is the additive analogue of
  `Valuation.map_sum_eq_of_lt`.

* `kapranov_easy_direction` — **the Fundamental Theorem of Tropical Geometry (easy direction,
  Kapranov).**  If a point lies on the classical hypersurface `{∑ Tᵢ = 0}` (and not all terms
  vanish), then its tropicalization lies on the *corner locus*: the tropicalized minimum
  `minᵢ v(Tᵢ)` is attained at least twice.  This is exactly the statement that the
  tropicalization of a variety is contained in the corner locus of the tropical polynomial.

* `TropPoly.eval_mul` — **min-plus multiplicativity.**  Tropical evaluation turns the product
  of tropical polynomials into the (ordinary) sum of their evaluations,
  `eval (P ⊙ Q) = eval P + eval Q`.  This is the engine of *tropical Bézout*: it makes degrees
  add and hypersurfaces of products decompose.

* `attainedTwice_subsingleton` — boundary case: a one-term (univariate, single monomial) tropical
  polynomial has empty corner locus, so the easy direction genuinely needs ≥ 2 monomials.

## The "limit of valuations" picture

Classically one studies the family `v_t = t · v` for `t → ∞` (the valuation "going to infinity"
rescales the amoeba); the corner-locus characterization proven here is the invariant limiting
shape.  See `FUTURE_DIRECTIONS.md`.
-/

open Finset

namespace TropicalValuationBridge

/-! ## §1. The corner locus / tropical hypersurface predicate -/

/-- A weight function `w : ι → α` **attains its minimum at least twice** when there are two
distinct indices, each of which is a global minimum.  Geometrically this is the *corner locus*
(tropical hypersurface) condition: the piecewise-linear tropical polynomial is non-smooth, i.e.
the minimum defining it is achieved by (at least) two monomials. -/
def AttainedAtLeastTwice {ι α : Type*} [LinearOrder α] (w : ι → α) : Prop :=
  ∃ i j, i ≠ j ∧ (∀ k, w i ≤ w k) ∧ (∀ k, w j ≤ w k)

/-
!-- A single index can never witness `i ≠ j`, so the corner locus of a one-monomial
tropical polynomial is empty. This is the boundary case where the bridge theorem fails. -- !--

**Boundary case.** With at most one index the corner locus is empty: a single tropical
monomial defines a smooth (linear) function with no corners.
-/
theorem attainedTwice_subsingleton {ι α : Type*} [LinearOrder α] [Subsingleton ι]
    (w : ι → α) : ¬ AttainedAtLeastTwice w := by
  rintro ⟨ i, j, hij, hi, hj ⟩ ; exact hij ( Subsingleton.elim i j )

/-! ## §2. The ultrametric "winner takes all" lemma for additive valuations -/

/-
!-- Strip the unique minimiser `j` off the sum; the remaining terms all have strictly
larger valuation, so by `map_lt_sum` their sum does too, and `map_add_eq` of distinct
valuations gives `v(∑) = v(f j)`. -- !--

If, among a finite family, the term `f j` has *strictly* the smallest valuation, then the
valuation of the whole sum equals `v (f j)`.  Additive analogue of
`Valuation.map_sum_eq_of_lt`.
-/
theorem addValuation_sum_eq_of_unique_min
    {K Γ ι : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) {s : Finset ι} {f : ι → K} {j : ι}
    (hj : j ∈ s) (hmin : ∀ i ∈ s, i ≠ j → v (f j) < v (f i)) :
    v (∑ i ∈ s, f i) = v (f j) := by
  classical
  by_cases h : v (f j) = ⊤
  · -- The unique minimiser has valuation ⊤, hence is the *maximum*, forcing `s = {j}`.
    have hs : s = {j} := by
      refine Finset.eq_singleton_iff_unique_mem.2 ⟨hj, ?_⟩
      intro i hi
      by_contra hne
      have hlt := hmin i hi hne
      rw [h] at hlt
      exact not_top_lt hlt
    rw [hs, Finset.sum_singleton]
  · rw [Finset.sum_eq_add_sum_diff_singleton hj]
    apply AddValuation.map_add_eq_of_lt_left
    refine v.map_lt_sum h ?_
    intro i hi
    rw [Finset.mem_sdiff, Finset.mem_singleton] at hi
    exact hmin i hi.1 hi.2

/-! ## §3. The Fundamental Theorem of Tropical Geometry — easy direction (Kapranov) -/

/-
!-- If the tropicalized minimum were attained uniquely at `m`, the winner-takes-all lemma
would give `v(∑ Tᵢ) = v(T m) ≠ ⊤`; but `∑ Tᵢ = 0` forces `v(∑) = ⊤`, a contradiction.
Hence the minimum is attained at least twice: the tropicalized point is on the corner locus. -- !--

**Tropicalization is contained in the corner locus.**  Let `K` be a non-Archimedean valued
field and `T : ι → K` the (finite, nonempty) family of monomials of a polynomial evaluated at a
point.  If that point lies on the hypersurface `∑ᵢ Tᵢ = 0` and the polynomial does not vanish
identically there (`∃ i, Tᵢ ≠ 0`), then the tropicalized weights `i ↦ v (Tᵢ)` attain their
minimum at least twice — the image point lies on the tropical hypersurface.
-/
theorem kapranov_easy_direction
    {K Γ ι : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ] [Nontrivial Γ]
    [Fintype ι] [Nonempty ι]
    (v : AddValuation K Γ) (T : ι → K)
    (hsum : ∑ i, T i = 0) (hnz : ∃ i, T i ≠ 0) :
    AttainedAtLeastTwice (fun i => v (T i)) := by
  obtain ⟨ m, hm ⟩ := Finset.exists_min_image Finset.univ ( fun i => v ( T i ) ) ⟨ hnz.choose, Finset.mem_univ _ ⟩;
  by_contra! h_contra
  have h_min : ∀ i, i ≠ m → v (T m) < v (T i) := by
    intro i hi; exact lt_of_le_of_ne ( hm.2 i ( Finset.mem_univ i ) ) ( fun h => h_contra ⟨ m, i, by aesop ⟩ ) ;
  have h_eq : v (∑ i, T i) = v (T m) := by
    apply addValuation_sum_eq_of_unique_min v (Finset.mem_univ m) (fun i hi hi' => h_min i hi')
  have h_contra' : v (T m) = ⊤ := by
    rw [ ← h_eq, hsum, v.map_zero ]
  exact (by
  obtain ⟨ i, hi ⟩ := hnz; specialize h_min i; simp_all +decide ;)

/-
**Tropical line / classical line corner.**  A concrete instance of the bridge:
if `(x, y)` is a point of the classical line `a·X + b·Y + c = 0` with `a, b, c` not all giving
a degenerate term, then the tropical line `min(v a + X, v b + Y, v c)` has a corner at
`(v(a·x), v(b·y), v c)`.
-/
theorem tropical_line_corner
    {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ] [Nontrivial Γ]
    (v : AddValuation K Γ) (a b c x y : K)
    (hline : a * x + b * y + c = 0) (hnz : a * x ≠ 0 ∨ b * y ≠ 0 ∨ c ≠ 0) :
    AttainedAtLeastTwice (fun i : Fin 3 => v (![a * x, b * y, c] i)) := by
  -- Apply the kapranov_easy_direction theorem with the given hypotheses.
  apply kapranov_easy_direction v ![a * x, b * y, c];
  · simp +decide [ Fin.sum_univ_three, hline ];
  · rcases hnz with ( h | h | h ) <;> [ exact ⟨ 0, h ⟩ ; exact ⟨ 1, h ⟩ ; exact ⟨ 2, h ⟩ ]

/-! ## §4. Min-plus multiplicativity → tropical Bézout's degree law -/

/-
Min-plus distributivity: the infimum over a product of a separated sum factors as the sum of
the infima.  `min_{(i,k)} (f i + g k) = (min_i f i) + (min_k g k)`.
-/
theorem inf'_product_add
    {ι κ : Type*} {s : Finset ι} {t : Finset κ} (hs : s.Nonempty) (ht : t.Nonempty)
    (f : ι → ℝ) (g : κ → ℝ) :
    (s ×ˢ t).inf' (hs.product ht) (fun p => f p.1 + g p.2)
      = s.inf' hs f + t.inf' ht g := by
  refine' le_antisymm _ _ <;> simp_all +decide
  · obtain ⟨ a, ha ⟩ := Finset.exists_mem_eq_inf' hs f; obtain ⟨ b, hb ⟩ := Finset.exists_mem_eq_inf' ht g; use a, b; aesop;
  · exact fun a b ha hb => add_le_add ( Finset.inf'_le _ ha ) ( Finset.inf'_le _ hb )

/-- A tropical polynomial in `n` variables: a finite family of monomials, each a real coefficient
together with a (real) exponent vector. -/
structure TropPoly (ι : Type*) (n : ℕ) where
  /-- The tropical coefficient of each monomial. -/
  coeff : ι → ℝ
  /-- The exponent vector of each monomial. -/
  exp : ι → (Fin n → ℝ)

/-- The value of the `i`-th monomial at the tropical point `x`: `coeff i + ⟨exp i, x⟩`. -/
def TropPoly.termVal {ι : Type*} {n : ℕ} (P : TropPoly ι n) (x : Fin n → ℝ) (i : ι) : ℝ :=
  P.coeff i + ∑ k, P.exp i k * x k

/-- Tropical (min-plus) evaluation of a tropical polynomial at a point. -/
noncomputable def TropPoly.eval {ι : Type*} {n : ℕ} [Fintype ι] [Nonempty ι]
    (P : TropPoly ι n) (x : Fin n → ℝ) : ℝ :=
  univ.inf' univ_nonempty (P.termVal x)

/-- Tropical (min-plus) product of two tropical polynomials: monomials multiply by adding
coefficients and exponents. -/
def TropPoly.mul {ι κ : Type*} {n : ℕ} (P : TropPoly ι n) (Q : TropPoly κ n) :
    TropPoly (ι × κ) n where
  coeff := fun p => P.coeff p.1 + Q.coeff p.2
  exp := fun p => P.exp p.1 + Q.exp p.2

/-
!-- The `(i,k)` monomial value of `P ⊙ Q` splits as `termVal P i + termVal Q k`; taking the
min over the product `univ ×ˢ univ` and applying `inf'_product_add` factors the result. -- !--

**Min-plus multiplicativity (engine of tropical Bézout).**  Tropical evaluation sends the
product of tropical polynomials to the ordinary sum of evaluations.  In particular Newton
polytopes (and hence degrees) add, the combinatorial heart of the tropical Bézout theorem.
-/
theorem TropPoly.eval_mul {ι κ : Type*} {n : ℕ}
    [Fintype ι] [Nonempty ι] [Fintype κ] [Nonempty κ]
    (P : TropPoly ι n) (Q : TropPoly κ n) (x : Fin n → ℝ) :
    (P.mul Q).eval x = P.eval x + Q.eval x := by
  convert inf'_product_add ( Finset.univ_nonempty : Finset.Nonempty ( Finset.univ : Finset ι ) ) ( Finset.univ_nonempty : Finset.Nonempty ( Finset.univ : Finset κ ) ) ( fun i => P.coeff i + ∑ k, P.exp i k * x k ) ( fun j => Q.coeff j + ∑ k, Q.exp j k * x k ) using 1;
  unfold TropPoly.eval TropPoly.termVal TropPoly.mul;
  simp +decide [ add_mul, Finset.sum_add_distrib, add_assoc, add_left_comm ]

/-! ## §5. Strengthening: leading-term cancellation forces a corner -/

/-
!-- If `m` is a minimal term yet the valuation of the *sum* strictly exceeds `v (T m)`, the
leading term cannot win alone; were `m` the unique strict minimiser the winner-takes-all lemma
would force `v(∑) = v(T m)`, contradicting the jump. -- !--

**Strengthening of `kapranov_easy_direction`.**  The hypothesis `∑ Tᵢ = 0` is only used through
the weaker fact that the valuation of the sum *strictly exceeds* the minimal term valuation
("leading-term cancellation").  This captures, e.g., points where `f` does not vanish but its
valuation jumps — and it still pins the tropicalized point onto the corner locus.
`kapranov_easy_direction` is the special case `∑ Tᵢ = 0` (so `v(∑) = ⊤`).
-/
theorem corner_of_leading_cancellation
    {K Γ ι : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    [Fintype ι] [Nonempty ι]
    (v : AddValuation K Γ) (T : ι → K) (m : ι)
    (hm : ∀ k, v (T m) ≤ v (T k))
    (hjump : v (T m) < v (∑ i, T i)) :
    AttainedAtLeastTwice (fun i => v (T i)) := by
  contrapose! hjump;
  refine' le_of_not_gt fun h => hjump ⟨ m, _ ⟩;
  obtain ⟨j, hj⟩ : ∃ j, j ≠ m ∧ v (T j) ≤ v (T m) := by
    contrapose! h;
    convert addValuation_sum_eq_of_unique_min v ( Finset.mem_univ m ) ( fun i _ hi => h i hi ) |> le_of_eq;
  exact ⟨ j, Ne.symm hj.1, hm, fun k => le_trans hj.2 ( hm k ) ⟩

end TropicalValuationBridge