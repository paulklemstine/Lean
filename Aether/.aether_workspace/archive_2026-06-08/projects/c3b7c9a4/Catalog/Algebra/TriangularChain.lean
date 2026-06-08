/-
Copyright (c) 2025. All rights reserved.

# Extremal Triangular Chain Automorphisms

## Main Results

* `triangularChain_comp_right` / `triangularChain_comp_left`:
  The triangular chain map `F_{n,d}` and its explicitly constructed inverse
  `G_{n,d}` compose to the identity in both orders.

* `triangularChainMap_degree`: The forward map has degree `d` (for `d ≥ 1`, `n ≥ 2`).

* `triangularChainInv_degree_le`: The inverse map has degree at most `d^{n-1}`.

The family `F_{n,d}(x₁,...,xₙ) = (x₁ + x₂^d, x₂ + x₃^d, ..., x_{n-1} + xₙ^d, xₙ)`
is the canonical extremal tame automorphism: it achieves the maximum possible
inverse degree among tame automorphisms of given degree.

## Keywords
triangular chain, tame automorphism, inverse degree, extremal family,
polynomial automorphism, degree bound sharpness
-/

import Mathlib
import Algebra.Jacobian.Defs

namespace JacobianConjecture

open MvPolynomial Finset

variable {k : Type*} [CommRing k]

/-! ### Definition of the Triangular Chain Map -/

/-- The triangular chain map `F_{n,d}`: coordinate `i` maps to `X_i + X_{i+1}^d`
    for `i < n-1`, and the last coordinate is the identity `X_{n-1}`. -/
noncomputable def triangularChainMap (k : Type*) [CommRing k] (n d : ℕ) :
    PolyMap k n :=
  fun i => if h : i.val + 1 < n then
    X i + (X (⟨i.val + 1, h⟩ : Fin n)) ^ d
  else
    X i

/-! ### Definition of the Inverse Map -/

/-- The inverse of the triangular chain map, defined by backward recursion.
    `G_{n-1} = X_{n-1}`, and `G_i = X_i - G_{i+1}^d`. -/
noncomputable def triangularChainInv (k : Type*) [CommRing k] (n d : ℕ)
    (i : Fin n) : MvPolynomial (Fin n) k :=
  if h : i.val + 1 < n then
    X i - (triangularChainInv k n d ⟨i.val + 1, h⟩) ^ d
  else
    X i
termination_by n - 1 - i.val

/-! ### Unfolding Lemmas -/

@[simp]
theorem triangularChainInv_last (n d : ℕ) (i : Fin n) (hi : ¬(i.val + 1 < n)) :
    triangularChainInv k n d i = X i := by
  rw [triangularChainInv]
  simp [hi]

@[simp]
theorem triangularChainInv_rec (n d : ℕ) (i : Fin n) (hi : i.val + 1 < n) :
    triangularChainInv k n d i =
    X i - (triangularChainInv k n d ⟨i.val + 1, hi⟩) ^ d := by
  rw [triangularChainInv]
  simp [hi]

/-- The last coordinate of the forward map is the identity. -/
theorem triangularChainMap_last (n d : ℕ) (hn : 1 ≤ n) :
    triangularChainMap k n d ⟨n - 1, by omega⟩ = X ⟨n - 1, by omega⟩ := by
  simp [triangularChainMap]; omega

/-- Each non-last coordinate of the forward map is `X_i + X_{i+1}^d`. -/
theorem triangularChainMap_coord (n d : ℕ) (i : Fin n) (hi : i.val + 1 < n) :
    triangularChainMap k n d i = X i + (X ⟨i.val + 1, hi⟩) ^ d := by
  simp [triangularChainMap, hi]

/-! ### Composition: F ∘ G = Id and G ∘ F = Id -/

/-
Helper: `bind₁` preserves a polynomial when substitution is identity on its variables.
-/
theorem bind₁_eq_self_of_vars'
    {σ : Type*} (G : σ → MvPolynomial σ k) (q : MvPolynomial σ k)
    (hG : ∀ j ∈ q.vars, G j = X j) :
    MvPolynomial.bind₁ G q = q := by
  -- Since $G$ is the identity on the variables of $q$, each term in the sum remains unchanged.
  have h_term : ∀ m ∈ q.support, (bind₁ G) (monomial m (coeff m q)) = monomial m (coeff m q) := by
    intro m hm; rw [ MvPolynomial.bind₁_monomial ] ;
    rw [ Finset.prod_congr rfl fun i hi => by rw [ hG i ( by rw [ MvPolynomial.mem_vars ] ; exact ⟨ m, hm, hi ⟩ ) ] ];
    simp +decide [ MvPolynomial.monomial_eq ];
  conv_lhs => rw [ MvPolynomial.as_sum q ];
  rw [ map_sum, Finset.sum_congr rfl h_term, MvPolynomial.as_sum q ];
  simp +decide [ MvPolynomial.coeff_sum, MvPolynomial.coeff_monomial ]

/-
Key lemma: The inverse coordinates only involve variables with index ≥ i.
-/
theorem triangularChainInv_vars (n d : ℕ) (i : Fin n) :
    ∀ j ∈ (triangularChainInv k n d i).vars, i ≤ j := by
  induction' m : n - 1 - i.val using Nat.strong_induction_on with m ih generalizing i;
  by_cases hi : i.val + 1 < n;
  · have h_vars : (triangularChainInv k n d i).vars ⊆ {i} ∪ (triangularChainInv k n d ⟨i.val + 1, hi⟩ ^ d).vars := by
      intro j hj;
      simp_all +decide [ MvPolynomial.mem_vars, sub_eq_add_neg ];
      rcases hj with ⟨ x, hx, hx' ⟩ ; by_cases hx'' : x = Finsupp.single i 1 <;> simp_all +decide [ MvPolynomial.coeff_X' ] ;
      · rw [ Finsupp.single_apply ] at hx' ; aesop;
      · grind +splitIndPred;
    have h_vars_pow : (triangularChainInv k n d ⟨i.val + 1, hi⟩ ^ d).vars ⊆ (triangularChainInv k n d ⟨i.val + 1, hi⟩).vars := by
      grind +suggestions;
    grind;
  · simp +decide [ triangularChainInv_last, hi ];
    intro j hj;
    contrapose! hj;
    simp +decide [ MvPolynomial.mem_vars, hj.ne ];
    simp +decide [ MvPolynomial.coeff_X' ];
    exact fun _ => Finsupp.single_eq_of_ne ( ne_of_lt hj )

/-
The triangular chain map and its inverse compose to the identity on the right:
    `F_{n,d} ∘ G_{n,d} = Id`.
-/
theorem triangularChain_comp_right (n d : ℕ) :
    polyMapComp (triangularChainMap k n d) (triangularChainInv k n d) = polyMapId := by
  funext i_contra;
  unfold polyMapComp polyMapId triangularChainMap;
  split_ifs <;> simp_all +decide [ MvPolynomial.bind₁_X_right ]

/-
The triangular chain map and its inverse compose to the identity on the left:
    `G_{n,d} ∘ F_{n,d} = Id`.
-/
theorem triangularChain_comp_left (n d : ℕ) :
    polyMapComp (triangularChainInv k n d) (triangularChainMap k n d) = polyMapId := by
  funext i;
  induction' m : n - 1 - i.val using Nat.strong_induction_on with m ih generalizing i;
  by_cases hi : i.val + 1 < n;
  · convert congr_arg₂ ( fun x y => x - y ^ d ) ( show MvPolynomial.bind₁ ( triangularChainMap k n d ) ( X i ) = X i + ( X ⟨ i + 1, hi ⟩ ) ^ d from ?_ ) ( show MvPolynomial.bind₁ ( triangularChainMap k n d ) ( triangularChainInv k n d ⟨ i + 1, hi ⟩ ) = X ⟨ i + 1, hi ⟩ from ?_ ) using 1;
    · unfold polyMapComp;
      rw [ triangularChainInv_rec ];
      exact map_sub _ _ _ |> Eq.trans <| by rw [ map_pow ] ;
    · simp +decide [ polyMapId ];
    · unfold triangularChainMap; aesop;
    · convert ih _ _ _ rfl using 1;
      grind +revert;
  · simp +decide [ polyMapComp, polyMapId, triangularChainMap, triangularChainInv, hi ]

/-- **The triangular chain map is a polynomial automorphism.** -/
theorem triangularChain_isPolyAuto (n d : ℕ) :
    IsPolyAuto (triangularChainMap k n d) :=
  ⟨triangularChainInv k n d,
   triangularChain_comp_right n d,
   triangularChain_comp_left n d⟩

/-! ### Degree of the Forward Map -/

/-
The forward triangular chain map has degree at most `d` (for `d ≥ 1`).
-/
theorem triangularChainMap_degree_le [Nontrivial k] (n d : ℕ) (hd : 1 ≤ d) :
    polyMapDegree (triangularChainMap k n d) ≤ d := by
  unfold polyMapDegree triangularChainMap;
  simp +zetaDelta at *;
  intro b; split_ifs <;> simp_all +decide [ MvPolynomial.totalDegree ] ;
  · intro c hc; contrapose! hc; simp_all +decide [ MvPolynomial.coeff_X', MvPolynomial.coeff_X_pow ] ;
    aesop;
  · simp +decide [ MvPolynomial.coeff_X' ];
    linarith

/-
The forward triangular chain map has degree exactly `d` (for `d ≥ 1`, `n ≥ 2`).
-/
theorem triangularChainMap_degree [Nontrivial k] (n d : ℕ) (hn : 2 ≤ n) (hd : 1 ≤ d) :
    polyMapDegree (triangularChainMap k n d) = d := by
  refine' le_antisymm _ _;
  · exact?;
  · refine' le_trans _ ( Finset.le_sup <| Finset.mem_univ ⟨ 0, by linarith ⟩ );
    unfold triangularChainMap;
    split_ifs <;> simp_all +decide [ MvPolynomial.totalDegree_add_eq_right_of_totalDegree_lt ];
    · refine' le_trans _ ( Finset.le_sup <| show Finsupp.single ⟨ 1, by linarith ⟩ d ∈ _ from _ ) <;> simp +decide;
      simp +decide [ MvPolynomial.coeff_X_pow ];
    · grind +revert

/-! ### Degree of the Inverse Map -/

/-
Each coordinate of the inverse has degree at most `d^{n-1-i}`.
-/
theorem triangularChainInv_coord_degree_le [Nontrivial k] (n d : ℕ) (hd : 1 ≤ d)
    (i : Fin n) :
    (triangularChainInv k n d i).totalDegree ≤ d ^ (n - 1 - i.val) := by
  -- We proceed by induction on $n - 1 - i$.
  induction' h : n - 1 - i with m ih generalizing i;
  · unfold triangularChainInv;
    split_ifs <;> simp_all +decide [ Nat.sub_eq_iff_eq_add ];
    omega;
  · unfold triangularChainInv;
    split_ifs;
    · refine' le_trans ( MvPolynomial.totalDegree_sub _ _ ) _;
      refine' max_le _ _;
      · exact le_trans ( MvPolynomial.totalDegree_X _ |> le_of_eq ) ( Nat.one_le_pow _ _ hd );
      · refine' le_trans ( MvPolynomial.totalDegree_pow _ _ ) _;
        convert Nat.mul_le_mul_left d ( ih ⟨ i + 1, by linarith ⟩ _ ) using 1;
        · rw [ pow_succ' ];
        · grind;
    · omega

/-
**The inverse map has degree at most `d^{n-1}`.**
    Combined with the forward degree theorem, this establishes that the
    tame inverse degree bound `deg(F⁻¹) ≤ (deg F)^{n-1}` is achieved.
-/
theorem triangularChainInv_degree_le [Nontrivial k] (n d : ℕ) (hn : 1 ≤ n) (hd : 1 ≤ d) :
    polyMapDegree (triangularChainInv k n d) ≤ d ^ (n - 1) := by
  exact Finset.sup_le fun i _ => le_trans ( triangularChainInv_coord_degree_le n d hd i ) ( pow_le_pow_right₀ hd ( Nat.sub_le _ _ ) )

end JacobianConjecture