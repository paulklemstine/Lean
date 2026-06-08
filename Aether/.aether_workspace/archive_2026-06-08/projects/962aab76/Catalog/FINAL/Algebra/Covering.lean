import Mathlib

/-!
# Agreement Geometry: Covering and List-Decoding Bounds

This file establishes the combinatorial and algebraic foundations of agreement geometry
for low-degree functions on finite sets. The main results are:

1. **Pairwise disjoint family bound** (`pairwise_disjoint_family_card_bound`):
   If a family of pairwise disjoint subsets of a finite type each have size ≥ s,
   then the number of sets times s is at most |X|.

2. **Polynomial root bound on a finite set** (`card_roots_filter_le_natDegree`):
   A nonzero polynomial of degree ≤ d has at most d roots in any finite set S.

3. **Evaluation equality bound** (`card_eval_eq_filter_le`):
   For distinct polynomials p, q of degree ≤ d over a field,
   |{x ∈ S : p(x) = q(x)}| ≤ d.

4. **Agreement intersection containment** (`agreeSet_inter_subset_evalEq`):
   agree(p, f) ∩ agree(q, f) ⊆ {x ∈ S : p(x) = q(x)}.

5. **Pairwise agreement overlap bound** (`agreeSet_inter_card_le`):
   For distinct p, q of degree ≤ d, |agree(p) ∩ agree(q)| ≤ d.

6. **Union-of-agreements lower bound** (`agreement_union_card_lower_bound`):
   For L distinct degree-≤-d polynomials each agreeing with f on ≥ t points,
   the union of agreement sets has size ≥ L*t - L*(L-1)/2 * d
   (Bonferroni first inclusion-exclusion bound).

7. **Univariate list-decoding bound** (`univariate_list_bound_bonferroni`):
   2 * L * t ≤ 2 * |S| + L * (L - 1) * d, giving a quadratic constraint
   on the list size L.

These results form a machine-checked foundation for certified list-size bounds
in algebraic coding theory and Reed-Solomon list decoding.
-/

open Finset Fintype Polynomial

/-! ## Part 1: Combinatorial Covering Bounds -/

/-
**Pairwise disjoint family bound.**
If a family of pairwise disjoint `Finset`s over a `Fintype`, each of cardinality ≥ s,
then the number of sets times s is at most the cardinality of the ambient type.
-/
theorem pairwise_disjoint_family_card_bound
    {X ι : Type*} [Fintype X] [DecidableEq X] [Fintype ι] [DecidableEq ι]
    (B : ι → Finset X) (s : ℕ)
    (hdisj : ∀ i j : ι, i ≠ j → Disjoint (B i) (B j))
    (hsize : ∀ i, s ≤ (B i).card) :
    Fintype.card ι * s ≤ Fintype.card X := by
  have := Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => hsize i;
  rw [ ← Finset.card_biUnion ] at this;
  · simpa using this.trans ( Finset.card_le_univ _ );
  · exact fun i _ j _ hij => hdisj i j hij

/-! ## Part 2: Polynomial Root Bounds -/

/-
A nonzero polynomial over a field has at most `natDegree` roots in any finite set.
-/
theorem card_roots_filter_le_natDegree
    {K : Type*} [Field K] [DecidableEq K]
    (S : Finset K) (p : Polynomial K) (hp : p ≠ 0) :
    (S.filter (fun x => p.IsRoot x)).card ≤ p.natDegree := by
  exact le_trans ( Finset.card_le_card ( show _ ⊆ p.roots.toFinset by aesop_cat ) ) ( Multiset.toFinset_card_le _ ) |> fun h ↦ h.trans ( Polynomial.card_roots' _ )

/-
For distinct polynomials p ≠ q of degree ≤ d, the set of points where they
agree has at most d elements.
-/
theorem card_eval_eq_filter_le
    {K : Type*} [Field K] [DecidableEq K]
    (S : Finset K) {p q : Polynomial K} (d : ℕ)
    (hpq : p ≠ q) (hp : p.natDegree ≤ d) (hq : q.natDegree ≤ d) :
    (S.filter (fun x => Polynomial.eval x p = Polynomial.eval x q)).card ≤ d := by
  have h_card_roots : (S.filter (fun x => (p - q).IsRoot x)).card ≤ (p - q).natDegree := by
    convert card_roots_filter_le_natDegree S ( p - q ) ( sub_ne_zero.mpr hpq ) using 1;
  convert h_card_roots.trans _ using 2;
  · simp +decide [ sub_eq_zero ];
  · exact le_trans ( Polynomial.natDegree_sub_le _ _ ) ( max_le hp hq )

/-! ## Part 3: Agreement Sets and Their Properties -/

/-- The agreement set of a polynomial with a target function on a finite set. -/
noncomputable def agreeSetPoly {K : Type*} [CommRing K] [DecidableEq K]
    (S : Finset K) (p : Polynomial K) (f : K → K) : Finset K :=
  S.filter (fun x => Polynomial.eval x p = f x)

/-
Agreement intersection is contained in the evaluation equality set.
-/
theorem agreeSet_inter_subset_evalEq
    {K : Type*} [CommRing K] [DecidableEq K]
    (S : Finset K) (p q : Polynomial K) (f : K → K) :
    (agreeSetPoly S p f ∩ agreeSetPoly S q f) ⊆
      S.filter (fun x => Polynomial.eval x p = Polynomial.eval x q) := by
  -- Take any x in the intersection. By definition of agreeSetPoly, x is in S and p(x) = f(x) and q(x) = f(x). Therefore, p(x) = q(x).
  intro x hx
  simp [agreeSetPoly] at hx
  aesop

/-
For distinct polynomials of degree ≤ d, their agreement sets with any
target function overlap in at most d points.
-/
theorem agreeSet_inter_card_le
    {K : Type*} [Field K] [DecidableEq K]
    (S : Finset K) {p q : Polynomial K} (d : ℕ) (f : K → K)
    (hpq : p ≠ q) (hp : p.natDegree ≤ d) (hq : q.natDegree ≤ d) :
    (agreeSetPoly S p f ∩ agreeSetPoly S q f).card ≤ d := by
  exact le_trans ( Finset.card_le_card ( agreeSet_inter_subset_evalEq S p q f ) ) ( card_eval_eq_filter_le S d hpq hp hq )

/-! ## Part 4: Univariate List-Decoding Bound -/

/-
**Univariate list-decoding bound (Bonferroni form).**

For a list `P` of `L` distinct polynomials of degree ≤ `d` over a field `K`,
each agreeing with a target function `f` on at least `t` points of a finite set `S`:

  `2 * L * t ≤ 2 * |S| + L * (L - 1) * d`

This is the correct quadratic constraint on list size, following from the
Bonferroni inclusion-exclusion inequality and the polynomial root bound.
When `t` is large relative to `d` and `L`, this gives `L ≈ 2|S|/(2t - d)`.
-/
theorem univariate_list_bound_bonferroni
    {K : Type*} [Field K] [DecidableEq K]
    (S : Finset K) (d t : ℕ)
    (P : List (Polynomial K))
    (hnodup : P.Nodup)
    (f : K → K)
    (hdeg : ∀ p ∈ P, p.natDegree ≤ d)
    (hagree : ∀ p ∈ P, t ≤ (S.filter (fun x => Polynomial.eval x p = f x)).card) :
    2 * P.length * t ≤ 2 * S.card + P.length * (P.length - 1) * d := by
  -- By induction on the length of the list L.
  have h_ind : ∀ (L : List (Polynomial K)), L.Nodup → (∀ p ∈ L, p.natDegree ≤ d) → (∀ p ∈ L, t ≤ (S.filter (fun x => p.eval x = f x)).card) → (S.filter (fun x => ∃ v ∈ L, v.eval x = f x)).card ≥ L.length * t - L.length * (L.length - 1) * d / 2 := by
    intro L hL hdeg hagree;
    induction' L using List.reverseRecOn with p L ih;
    · simp +decide;
    · by_cases hp : p.Nodup <;> simp_all +decide [ List.nodup_append ];
      -- By the properties of the union of sets, we can split the cardinality into the sum of the cardinalities of the individual sets.
      have h_union : (S.filter (fun x => ∃ v ∈ p ++ [L], v.eval x = f x)).card ≥ (S.filter (fun x => ∃ v ∈ p, v.eval x = f x)).card + (S.filter (fun x => L.eval x = f x)).card - (S.filter (fun x => ∃ v ∈ p, v.eval x = f x ∧ L.eval x = f x)).card := by
        simp +decide [ Finset.filter_or, Finset.filter_and ];
        rw [ ← Finset.card_union_add_card_inter ];
        gcongr <;> simp +decide [ Finset.subset_iff ];
        · rintro x ( ⟨ hx₁, v, hv₁, hv₂ ⟩ | ⟨ hx₁, hx₂ ⟩ ) <;> [ exact ⟨ hx₁, v, Or.inl hv₁, hv₂ ⟩ ; exact ⟨ hx₁, L, Or.inr rfl, hx₂ ⟩ ];
        · exact fun x hx y hy hy' hx' hy'' => ⟨ hx, y, hy, hy', hy'' ⟩;
      -- By the properties of the intersection of sets, we can bound the cardinality of the intersection.
      have h_inter : (S.filter (fun x => ∃ v ∈ p, v.eval x = f x ∧ L.eval x = f x)).card ≤ p.length * d := by
        have h_inter : ∀ v ∈ p, (S.filter (fun x => v.eval x = f x ∧ L.eval x = f x)).card ≤ d := by
          intro v hv
          have h_inter : (S.filter (fun x => v.eval x = L.eval x)).card ≤ d := by
            apply card_eval_eq_filter_le S d (hL v hv) (hdeg v (Or.inl hv)) (hdeg L (Or.inr rfl));
          exact le_trans ( Finset.card_le_card fun x hx => by aesop ) h_inter;
        have h_inter : (S.filter (fun x => ∃ v ∈ p, v.eval x = f x ∧ L.eval x = f x)).card ≤ Finset.sum (p.toFinset) (fun v => (S.filter (fun x => v.eval x = f x ∧ L.eval x = f x)).card) := by
          have h_inter : (S.filter (fun x => ∃ v ∈ p, v.eval x = f x ∧ L.eval x = f x)).card ≤ Finset.card (Finset.biUnion (p.toFinset) (fun v => S.filter (fun x => v.eval x = f x ∧ L.eval x = f x))) := by
            exact Finset.card_le_card fun x hx => by aesop;
          exact h_inter.trans ( Finset.card_biUnion_le );
        exact h_inter.trans ( le_trans ( Finset.sum_le_sum fun x hx => ‹∀ v ∈ p, # ( { x ∈ S | eval x v = f x ∧ eval x L = f x } ) ≤ d› x ( List.mem_toFinset.mp hx ) ) ( by simp +decide [ List.toFinset_card_of_nodup hp ] ) );
      rcases p with ( _ | ⟨ x, _ | ⟨ y, p ⟩ ⟩ ) <;> simp_all +decide [ Nat.mul_succ, Nat.add_mul_div_left ];
      · grind +extAll;
      · grind;
  grind