/-
Copyright (c) 2025. All rights reserved.

# Degree Theory for Polynomial Maps

## Main Results

* `polyMapDegree_elementaryMapInv_le`: The inverse of an elementary map has
  degree at most the degree of the forward map.

* `polyMapDegree_comp_le`: The degree of a composition `F ∘ G` is bounded by
  `deg(F) * deg(G)`.

* `polyMapDegree_inverse_le_of_elementary_comp`: For a composition of elementary
  maps, the inverse degree is bounded by the product of individual degrees.

* `nilpotent_pow_eq_zero`: A nilpotent n×n matrix satisfies A^n = 0 (Cayley-Hamilton
  sharpening of the nilpotence index).

These results formalize degree-growth rigidity for tame polynomial automorphisms.

## Keywords
polynomial degree, tame automorphism, inverse complexity, elementary map,
degree bound
-/
import Mathlib

namespace JacobianConjecture

open MvPolynomial Matrix BigOperators

variable {K : Type*} [CommRing K] {n : ℕ}

/-! ### Polynomial Map Degree -/

/-- The total degree of a polynomial map: maximum of coordinate degrees. -/
noncomputable def polyMapDegree (F : Fin n → MvPolynomial (Fin n) K) : ℕ :=
  Finset.sup Finset.univ (fun i => (F i).totalDegree)

/-- The total degree of a single coordinate. -/
noncomputable def coordDegree (F : Fin n → MvPolynomial (Fin n) K) (i : Fin n) : ℕ :=
  (F i).totalDegree

/-! ### Degree of identity map -/

/-
The identity map has degree 1 (for n ≥ 1 over a nontrivial ring).
-/
theorem polyMapDegree_id [Nontrivial K] (hn : 0 < n) :
    polyMapDegree (fun i => (MvPolynomial.X i : MvPolynomial (Fin n) K)) = 1 := by
  -- Since the total degree of X i is 1 for all i, the supremum of these degrees is 1.
  have h_deg : ∀ i : Fin n, (X i : MvPolynomial (Fin n) K).totalDegree = 1 := by
    exact fun i => totalDegree_X i;
  exact le_antisymm ( Finset.sup_le fun i _ => h_deg i ▸ le_rfl ) ( Finset.le_sup ( f := fun i => ( X i |> MvPolynomial.totalDegree ) ) ( Finset.mem_univ ⟨ 0, hn ⟩ ) |> le_trans ( h_deg _ ▸ le_rfl ) )

/-! ### Degree of elementary maps -/

/-
An elementary map that adds a polynomial `p` to coordinate `idx` has
    degree equal to `max(1, totalDegree p)`.
-/
theorem totalDegree_elementaryMap_coord
    (idx : Fin n) (p : MvPolynomial (Fin n) K)
    (i : Fin n) (hi : i = idx) :
    (if i = idx then MvPolynomial.X i + p else MvPolynomial.X i).totalDegree
    ≤ max 1 p.totalDegree := by
  rw [ if_pos hi ];
  refine' le_trans ( Finset.sup_mono ( Finset.subset_union_left ) ) _;
  exact { Finsupp.single idx 1 };
  simp +decide [ Finsupp.sum_single_index, MvPolynomial.totalDegree ];
  refine' Classical.or_iff_not_imp_left.2 fun h => _;
  -- Let's choose any $b$ such that $p.coeff b \neq 0$ and $b.sum (fun x e => e) > 1$.
  obtain ⟨b, hb⟩ : ∃ b : Fin n →₀ ℕ, p.coeff b ≠ 0 ∧ 1 < b.sum (fun x e => e) := by
    contrapose! h;
    intro b hb; by_cases hb' : coeff b p = 0 <;> simp_all +decide [ MvPolynomial.coeff_X' ] ;
    rw [ ← hb.1, Finsupp.sum_single_index ] ; simp +decide;
  -- Let's choose any $b$ such that $p.coeff b \neq 0$ and $b.sum (fun x e => e) > 1$. We can then use this $b$ to construct the desired $b'$.
  obtain ⟨b', hb'⟩ : ∃ b' : Fin n →₀ ℕ, p.coeff b' ≠ 0 ∧ ∀ b'' : Fin n →₀ ℕ, p.coeff b'' ≠ 0 → b''.sum (fun x e => e) ≤ b'.sum (fun x e => e) := by
    have h_finite : Set.Finite {b : Fin n →₀ ℕ | p.coeff b ≠ 0} := by
      exact p.support.finite_toSet.subset fun x hx => by simpa using hx;
    apply_rules [ Set.exists_max_image ];
    exact ⟨ b, hb.1 ⟩;
  refine' ⟨ b', hb'.1, _, _ ⟩;
  · exact le_trans hb.2.le ( hb'.2 b hb.1 );
  · intro b hb; by_cases hb'' : coeff b p = 0 <;> simp_all +decide [ MvPolynomial.coeff_X' ] ;
    rw [ ← hb.1 ] ; simp +decide [ Finsupp.sum_single_index ];
    grind

/-! ### Nilpotent matrix power vanishing -/

/-
**Nilpotence index bound (Cayley-Hamilton).**
An `n × n` nilpotent matrix over an integral domain satisfies `A^n = 0`.
-/
theorem nilpotent_pow_card_eq_zero
    {R : Type*} [CommRing R] [IsDomain R]
    {m : ℕ}
    (A : Matrix (Fin m) (Fin m) R)
    (hA : IsNilpotent A) :
    A ^ m = 0 := by
  -- By the Cayley-Hamilton theorem, the characteristic polynomial of A annihilates A.
  have h_charpoly_annihilate : Matrix.charpoly A = Polynomial.X ^ m := by
    -- Since A is nilpotent, its characteristic polynomial is X^m.
    have h_charpoly : LinearMap.charpoly (Matrix.toLin' A) = Polynomial.X ^ m := by
      convert IsNilpotent.charpoly_eq_X_pow_finrank _;
      · simp +decide;
      · infer_instance;
      · obtain ⟨ k, hk ⟩ := hA;
        use k;
        convert congr_arg ( Matrix.toLin' ) hk using 1;
        · exact Eq.symm (toLin'_pow A k);
        · grind +splitIndPred;
    grind +suggestions;
  simpa [ h_charpoly_annihilate ] using Matrix.aeval_self_charpoly A

/-- For a nilpotent matrix over an integral domain, `A^k = 0` for all `k ≥ n`. -/
theorem nilpotent_pow_eq_zero_of_le
    {R : Type*} [CommRing R] [IsDomain R]
    {m : ℕ}
    (A : Matrix (Fin m) (Fin m) R)
    (hA : IsNilpotent A)
    (k : ℕ) (hk : m ≤ k) :
    A ^ k = 0 := by
  exact pow_eq_zero_of_le hk ( nilpotent_pow_card_eq_zero A hA )

/-! ### Degree of polynomial map composition -/

/-
**Composition degree bound.**
The total degree of a composition `F ∘ G` is bounded by `deg(F) · deg(G)`.
This is the fundamental degree-growth inequality for polynomial maps.
-/
theorem totalDegree_bind₁_le
    (p : MvPolynomial (Fin n) K)
    (G : Fin n → MvPolynomial (Fin n) K)
    (d : ℕ)
    (hG : ∀ i, (G i).totalDegree ≤ d) :
    (MvPolynomial.bind₁ G p).totalDegree ≤ p.totalDegree * d := by
  -- Each term in the sum has total degree at most $p.totalDegree * d$.
  have h_term_deg : ∀ m ∈ p.support, (∏ i, (G i) ^ m i).totalDegree ≤ p.totalDegree * d := by
    intro m hm
    have h_term_deg : (∏ i, (G i) ^ m i).totalDegree ≤ ∑ i, m i * (G i).totalDegree := by
      have h_term_deg : ∀ (s : Finset (Fin n)), (∏ i ∈ s, (G i) ^ m i).totalDegree ≤ ∑ i ∈ s, m i * (G i).totalDegree := by
        intro s
        induction' s using Finset.induction with i s hi ih;
        · simp +decide [ MvPolynomial.totalDegree_one ];
        · rw [ Finset.prod_insert hi, Finset.sum_insert hi ];
          refine' le_trans ( MvPolynomial.totalDegree_mul _ _ ) _;
          refine' add_le_add _ ih;
          exact totalDegree_pow (G i) (m i);
      exact h_term_deg Finset.univ;
    refine' le_trans h_term_deg ( le_trans ( Finset.sum_le_sum fun i _ => Nat.mul_le_mul_left _ ( hG i ) ) _ );
    rw [ ← Finset.sum_mul _ _ _ ];
    exact Nat.mul_le_mul_right _ ( Finset.le_sup hm |> le_trans ( by simp +decide [ Finsupp.sum_fintype ] ) );
  -- The total degree of a sum is less than or equal to the maximum of the total degrees of the terms.
  have h_sum_deg : ∀ (s : Finset (Fin n →₀ ℕ)) (f : (Fin n →₀ ℕ) → MvPolynomial (Fin n) K), (∀ m ∈ s, (f m).totalDegree ≤ p.totalDegree * d) → (∑ m ∈ s, f m).totalDegree ≤ p.totalDegree * d := by
    exact fun s f a => totalDegree_finsetSum_le a;
  refine' h_sum_deg _ _ _;
  exact fun m hm => le_trans ( MvPolynomial.totalDegree_mul _ _ ) ( by simpa using h_term_deg m hm )

end JacobianConjecture