/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Anisotropic Footprint Bound on Finite Cartesian Products

This file proves the Alon–Füredi / footprint bound for multivariate polynomials
on arbitrary finite Cartesian products over a field:

> Given finite nonempty sets S₁, ..., Sₙ ⊆ F and a nonzero polynomial f ∈ F[X₁,...,Xₙ]
> with deg_{Xᵢ}(f) ≤ eᵢ < |Sᵢ|, the number of points in ∏ᵢ Sᵢ where f does not
> vanish is at least ∏ᵢ (|Sᵢ| - eᵢ).

This upgrades the classical footprint bound from uniform coordinate alphabets (F_q^n)
to **anisotropic finite geometries** — the natural setting for coding theory with
unequal symbol sets and restricted interpolation.

## Main results

- `CartesianFootprint.exists_eval_ne_zero`: A nonzero reduced polynomial has at least
  one nonzero on the grid (restricted-grid combinatorial Nullstellensatz).
- `CartesianFootprint.footprint_bound`: The full quantitative lower bound on the
  number of nonzeros.

## References

- N. Alon, "Combinatorial Nullstellensatz", Combin. Probab. Comput. 8 (1999)
- S. Ball, O. Serra, "Punctured combinatorial Nullstellensätze", Combinatorica 29 (2009)
- H. López, C. Rentería-Márquez, R. Villarreal, "Affine Cartesian codes", Des. Codes Cryptogr. 71 (2014)
-/
import Bridges.Combinatorics.FootprintHelpers

open MvPolynomial Polynomial Finset BigOperators Classical

noncomputable section

namespace CartesianFootprint

/-! ## Definitions -/

/-- The finite Cartesian product ∏ᵢ Sᵢ as a `Finset` of functions `Fin n → F`. -/
def grid {n : ℕ} {F : Type*} [DecidableEq F] (S : Fin n → Finset F) : Finset (Fin n → F) :=
  Fintype.piFinset S

/-- A polynomial is **reduced on grid S** if every monomial in its support has
    each coordinate exponent strictly less than the corresponding set cardinality.
    This is the support-based surrogate for reduction modulo the coordinate
    vanishing ideal ⟨∏_{a∈Sᵢ}(Xᵢ-a) : i⟩. -/
def IsReducedOnGrid {n : ℕ} {F : Type*} [CommSemiring F]
    (S : Fin n → Finset F) (f : MvPolynomial (Fin n) F) : Prop :=
  ∀ i m, m ∈ f.support → m i < (S i).card

/-- The coordinate vanishing polynomial for the i-th coordinate:
    gᵢ(Xᵢ) = ∏_{a ∈ Sᵢ} (Xᵢ - a). -/
def coordVanishingPoly {n : ℕ} {F : Type*} [Field F]
    (S : Fin n → Finset F) (i : Fin n) : MvPolynomial (Fin n) F :=
  ∏ a ∈ S i, (MvPolynomial.X i - MvPolynomial.C a)

/-! ## Grid membership -/

@[simp]
theorem mem_grid {n : ℕ} {F : Type*} [DecidableEq F]
    {S : Fin n → Finset F} {x : Fin n → F} :
    x ∈ grid S ↔ ∀ i, x i ∈ S i :=
  Fintype.mem_piFinset

theorem grid_card {n : ℕ} {F : Type*} [DecidableEq F]
    (S : Fin n → Finset F) :
    (grid S).card = ∏ i, (S i).card :=
  Fintype.card_piFinset S

/-! ## Existence of nonzero evaluation (restricted-grid Nullstellensatz) -/

/-
**Restricted-grid Combinatorial Nullstellensatz.**
    A nonzero polynomial that is reduced on the grid ∏ᵢ Sᵢ
    (i.e., each monomial exponent in variable i is < |Sᵢ|)
    has at least one nonzero evaluation on the grid.
-/
theorem exists_eval_ne_zero {n : ℕ} {F : Type*} [Field F]
    (S : Fin n → Finset F)
    (hS : ∀ i, (S i).Nonempty)
    (f : MvPolynomial (Fin n) F)
    (hf : f ≠ 0)
    (hred : IsReducedOnGrid S f) :
    ∃ x ∈ grid (F := F) S, MvPolynomial.eval x f ≠ 0 := by
  revert hf hred;
  induction' n with n ih;
  · -- Since $f$ is a constant polynomial, we can write it as $f = c$ for some $c \in F$.
    obtain ⟨c, hc⟩ : ∃ c : F, f = MvPolynomial.C c := by
      exact ⟨ f.coeff 0, by rw [ MvPolynomial.eq_C_of_isEmpty f ] ; simp +decide ⟩;
    simp_all +decide [ IsReducedOnGrid ];
  · intro hf hred
    set P := (MvPolynomial.finSuccEquiv F n) f
    have hP : P ≠ 0 := by
      exact?
    obtain ⟨c, hc⟩ : ∃ c : MvPolynomial (Fin n) F, c ≠ 0 ∧ c = P.leadingCoeff ∧ IsReducedOnGrid (fun i => S (Fin.succ i)) c := by
      refine' ⟨ _, _, rfl, _ ⟩;
      · exact fun h => hP <| Polynomial.leadingCoeff_eq_zero.mp h;
      · intro i m hm;
        convert hred ( Fin.succ i ) ( Finsupp.cons ( P.natDegree ) m ) _ using 1;
        convert finSuccEquiv_coeff_support hm using 1;
    obtain ⟨ a, ha ⟩ := ih ( fun i => S ( Fin.succ i ) ) ( fun i => hS _ ) c hc.1 hc.2.2;
    -- Then `Q = Polynomial.map (MvPolynomial.eval a) P` is a nonzero univariate polynomial (since its leading coefficient is eval a c ≠ 0, use map_eval_ne_zero_of_leadingCoeff or similar argument).
    have hQ : (Polynomial.map (MvPolynomial.eval a) P) ≠ 0 := by
      exact fun h => ha.2 ( by simpa [ hc.2.1 ] using congr_arg ( fun p => p.coeff ( Polynomial.natDegree P ) ) h );
    -- Since S 0 is nonempty and has more elements than Q.natDegree, Q cannot vanish on all of S 0. More precisely, Q has ≤ Q.natDegree < (S 0).card roots, so there exists b ∈ S 0 with Q.eval b ≠ 0.
    obtain ⟨b, hb⟩ : ∃ b ∈ S 0, (Polynomial.eval b (Polynomial.map (MvPolynomial.eval a) P)) ≠ 0 := by
      have hQ_roots : (Finset.filter (fun b => Polynomial.eval b (Polynomial.map (MvPolynomial.eval a) P) = 0) (S 0)).card ≤ (Polynomial.map (MvPolynomial.eval a) P).natDegree := by
        exact le_trans ( Finset.card_le_card ( show _ ⊆ ( Polynomial.map ( MvPolynomial.eval a ) P |> Polynomial.roots |> Multiset.toFinset ) from fun x hx => by aesop ) ) ( by exact le_trans ( Multiset.toFinset_card_le _ ) ( Polynomial.card_roots' _ ) );
      have hQ_deg : (Polynomial.map (MvPolynomial.eval a) P).natDegree < (S 0).card := by
        refine' lt_of_le_of_lt ( map_eval_natDegree_le _ _ ) _;
        exact ( S 0 |> Finset.card ) - 1;
        · exact fun m hm => Nat.le_sub_one_of_lt ( hred 0 m hm );
        · exact Nat.pred_lt ( ne_bot_of_gt ( Finset.card_pos.mpr ( hS 0 ) ) );
      contrapose! hQ_deg;
      exact le_trans ( by rw [ Finset.filter_true_of_mem hQ_deg ] ) hQ_roots;
    refine' ⟨ Fin.cons b a, _, _ ⟩ <;> simp_all +decide [ grid ];
    · exact fun i => Fin.cases hb.1 ha.1 i;
    · convert hb.2 using 1;
      rw [ MvPolynomial.eval_eq_eval_mv_eval' ]

/-! ## Main theorem: Quantitative footprint bound -/

/-
**Anisotropic Footprint Bound (Alon–Füredi on arbitrary Cartesian products).**

    Let F be a field, Sᵢ ⊆ F finite nonempty sets, and f ∈ F[X₁,...,Xₙ] nonzero.
    If for each variable i, every monomial of f has exponent ≤ eᵢ < |Sᵢ| in Xᵢ,
    then the number of grid points where f ≠ 0 is at least ∏ᵢ (|Sᵢ| - eᵢ).
-/
theorem footprint_bound {n : ℕ} {F : Type*} [Field F]
    (S : Fin n → Finset F)
    (hS : ∀ i, (S i).Nonempty)
    (f : MvPolynomial (Fin n) F)
    (hf : f ≠ 0)
    (e : Fin n → ℕ)
    (he : ∀ i m, m ∈ f.support → m i ≤ e i)
    (helt : ∀ i, e i < (S i).card) :
    ∏ i, ((S i).card - e i) ≤
      ((grid (F := F) S).filter (fun x => MvPolynomial.eval x f ≠ 0)).card := by
  revert hf he;
  induction' n with n ih;
  · simp +decide [ grid ];
    rw [ MvPolynomial.eq_C_of_isEmpty f ] ; aesop;
  · intro hf he
    set P := (MvPolynomial.finSuccEquiv F n) f with hP
    have hP_ne_zero : P ≠ 0 := by
      exact CartesianFootprint.finSuccEquiv_ne_zero hf
    have hP_leadingCoeff_ne_zero : P.leadingCoeff ≠ 0 := by
      exact fun h => hP_ne_zero <| Polynomial.leadingCoeff_eq_zero.mp h;
    -- By the induction hypothesis, the number of nonzeros of $P.leadingCoeff$ on the grid $\prod_{i : Fin n} S (Fin.succ i)$ is at least $\prod_{i : Fin n} ((S (Fin.succ i)).card - e (Fin.succ i))$.
    have h_ind : (Finset.filter (fun x => (MvPolynomial.eval x) P.leadingCoeff ≠ 0) (grid (fun i => S (Fin.succ i)))).card ≥ (∏ i : Fin n, ((S (Fin.succ i)).card - e (Fin.succ i))) := by
      apply ih (fun i => S (Fin.succ i)) (fun i => hS (Fin.succ i)) P.leadingCoeff (fun i => e (Fin.succ i)) (fun i => helt (Fin.succ i)) hP_leadingCoeff_ne_zero (fun i m hm => by
        apply finSuccEquiv_leadingCoeff_support_bound hm i (fun m' hm' => he (Fin.succ i) m' hm'));
    -- For each $a \in \{x \in \text{grid}(S \circ \text{succ}) \mid \text{eval}(x, P.\text{leadingCoeff}) \neq 0\}$, the number of $b \in S 0$ such that $\text{eval}(b, \text{map}(\text{eval}(a), P)) \neq 0$ is at least $(S 0).card - e 0$.
    have h_eval : ∀ a ∈ Finset.filter (fun x => (MvPolynomial.eval x) P.leadingCoeff ≠ 0) (grid (fun i => S (Fin.succ i))), (Finset.filter (fun b => (Polynomial.eval b (Polynomial.map (MvPolynomial.eval a) P)) ≠ 0) (S 0)).card ≥ (S 0).card - e 0 := by
      intro a ha
      have h_eval_a : (Polynomial.map (MvPolynomial.eval a) P).natDegree ≤ e 0 := by
        apply map_eval_natDegree_le;
        exact he 0;
      have h_eval_a : (Finset.filter (fun b => (Polynomial.eval b (Polynomial.map (MvPolynomial.eval a) P)) = 0) (S 0)).card ≤ e 0 := by
        have h_eval_a : (Finset.filter (fun b => (Polynomial.eval b (Polynomial.map (MvPolynomial.eval a) P)) = 0) (S 0)).card ≤ (Polynomial.map (MvPolynomial.eval a) P).roots.toFinset.card := by
          refine Finset.card_le_card ?_;
          simp +contextual [ Finset.subset_iff ];
          intro x hx hx' hx''; simp_all +decide [ Polynomial.ext_iff ] ;
          exact ha.2 ( by rw [ Polynomial.leadingCoeff, hx'' ] );
        exact h_eval_a.trans ( le_trans ( Multiset.toFinset_card_le _ ) ( le_trans ( Polynomial.card_roots' _ ) ‹_› ) );
      rw [ Finset.filter_not, Finset.card_sdiff ] ; simp +decide [ Finset.card_sdiff ];
      rw [ Finset.inter_eq_left.mpr ( Finset.filter_subset _ _ ) ] ; omega;
    -- The number of nonzeros of $f$ on the grid $\prod_{i : Fin (n + 1)} S i$ is at least the sum of the number of nonzeros of $P$ on the grid $\prod_{i : Fin n} S (Fin.succ i)$ for each $a \in \{x \in \text{grid}(S \circ \text{succ}) \mid \text{eval}(x, P.\text{leadingCoeff}) \neq 0\}$.
    have h_sum : (Finset.filter (fun x => (MvPolynomial.eval x) f ≠ 0) (grid S)).card ≥ (∑ a ∈ Finset.filter (fun x => (MvPolynomial.eval x) P.leadingCoeff ≠ 0) (grid (fun i => S (Fin.succ i))), (Finset.filter (fun b => (Polynomial.eval b (Polynomial.map (MvPolynomial.eval a) P)) ≠ 0) (S 0)).card) := by
      have h_sum : (Finset.filter (fun x => (MvPolynomial.eval x) f ≠ 0) (grid S)) ⊇ Finset.biUnion (Finset.filter (fun x => (MvPolynomial.eval x) P.leadingCoeff ≠ 0) (grid (fun i => S (Fin.succ i)))) (fun a => Finset.image (fun b => Fin.cons b a) (Finset.filter (fun b => (Polynomial.eval b (Polynomial.map (MvPolynomial.eval a) P)) ≠ 0) (S 0))) := by
        simp +decide [ Finset.subset_iff ];
        rintro x a ha₁ ha₂ b hb₁ hb₂ rfl;
        refine' ⟨ fun i => _, _ ⟩;
        · refine' Fin.cases _ _ i <;> simp +decide [ * ];
        · convert hb₂ using 1;
          rw [ MvPolynomial.eval_eq_eval_mv_eval' ];
      refine' le_trans _ ( Finset.card_mono h_sum );
      rw [ Finset.card_biUnion ];
      · exact Finset.sum_le_sum fun x hx => by rw [ Finset.card_image_of_injective _ fun a b h => by simpa using congr_fun h 0 ] ;
      · intros a ha b hb hab;
        simp +decide [ Finset.disjoint_left, Function.onFun ];
        rintro _ x hx₁ hx₂ rfl y hy₁ hy₂; contrapose! hab; ext i; simp_all +decide [ Fin.forall_fin_succ ] ;
    refine' le_trans _ h_sum;
    refine' le_trans _ ( Finset.sum_le_sum h_eval );
    rw [Fin.prod_univ_succ]
    simp only [Finset.sum_const, smul_eq_mul]
    calc (# (S 0) - e 0) * ∏ i : Fin n, (# (S (Fin.succ i)) - e (Fin.succ i))
        ≤ (# (S 0) - e 0) * (Finset.filter (fun x => (MvPolynomial.eval x) P.leadingCoeff ≠ 0) (grid (fun i => S (Fin.succ i)))).card := by
          apply Nat.mul_le_mul_left; exact h_ind
      _ = (Finset.filter (fun x => (MvPolynomial.eval x) P.leadingCoeff ≠ 0) (grid (fun i => S (Fin.succ i)))).card * (# (S 0) - e 0) := by ring
      _ ≤ _ := by
          have : (Finset.filter (fun x => (MvPolynomial.eval x) P.leadingCoeff ≠ 0) (grid (fun i => S (Fin.succ i)))).card * (# (S 0) - e 0) = ∑ _ ∈ Finset.filter (fun x => (MvPolynomial.eval x) P.leadingCoeff ≠ 0) (grid (fun i => S (Fin.succ i))), (# (S 0) - e 0) := by
            rw [Finset.sum_const, smul_eq_mul]
          linarith [Finset.sum_le_sum h_eval]


/-! ## Corollaries -/

/-
Footprint bound using `degreeOf` instead of explicit exponent bounds.
-/
theorem footprint_bound_degreeOf {n : ℕ} {F : Type*} [Field F]
    (S : Fin n → Finset F)
    (hS : ∀ i, (S i).Nonempty)
    (f : MvPolynomial (Fin n) F)
    (hf : f ≠ 0)
    (hdeg : ∀ i, f.degreeOf i < (S i).card) :
    ∏ i, ((S i).card - f.degreeOf i) ≤
      ((grid (F := F) S).filter (fun x => MvPolynomial.eval x f ≠ 0)).card := by
  convert footprint_bound S hS f hf ( fun i => f.degreeOf i ) _ _;
  · grind +suggestions;
  · exact hdeg

/-
**Uniform grid specialization.**
    When all Sᵢ = S (same set), and all degree bounds are d,
    the number of nonzeros is at least (|S| - d)ⁿ.
    This recovers the classical footprint bound on Fqⁿ.
-/
theorem uniform_grid_footprint_bound {n : ℕ} {F : Type*} [Field F]
    (S₀ : Finset F) (hS₀ : S₀.Nonempty)
    (f : MvPolynomial (Fin n) F)
    (hf : f ≠ 0)
    (d : ℕ) (hd : d < S₀.card)
    (he : ∀ i m, m ∈ f.support → m i ≤ d) :
    (S₀.card - d) ^ n ≤
      ((grid (F := F) (fun _ => S₀)).filter (fun x => MvPolynomial.eval x f ≠ 0)).card := by
  -- Apply the footprint bound with e = fun _ => d and S = fun _ => S₀.
  have := footprint_bound (fun _ => S₀) (fun _ => hS₀) f hf (fun _ => d) (fun i m hm => he i m hm) (fun i => hd);
  rwa [ Finset.prod_const, Finset.card_fin ] at this

end CartesianFootprint