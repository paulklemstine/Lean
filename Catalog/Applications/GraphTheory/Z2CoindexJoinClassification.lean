/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib
import Novelty.GraphTheory.Z2CoindexJoin

/-!
# Classification of finite free ℤ₂-sets and the sharp join law in full generality

This file *deepens* `Novelty.Z2CoindexJoin`, which established the constructive lower-bound half of
the join law for the `ℤ₂`-coindex, `coind(K ⋆ L) ≥ coind(K) + coind(L) + 1`, together with the
*sharp* value on the octahedral tower `Oct`.  The companion file remarked that the matching upper
bound for **arbitrary** free `ℤ₂`-sets "is a genuine equivariant cohomological obstruction ...
beyond this combinatorial model."

The main discovery of the present development is that, **within the octahedral combinatorial model,
this obstruction is not needed at all**: the coindex is a *complete* invariant of a finite free
`ℤ₂`-set.  Concretely:

* every `ℤ₂`-map is injective on vertices (`GMap.toFun_injective`);
* consequently a finite free `ℤ₂`-set with `2(m+1)` vertices admits no equivariant simplicial map
  from a larger octahedral sphere (`gmap_card_le`) — a Borsuk–Ulam-type bound valid for *every*
  finite free `ℤ₂`-set, not merely the octahedral ones;
* the coindex supremum is *attained* (`nonempty_gmap_coind`);
* **classification** (`exists_oct_iso`): every finite nonempty free `ℤ₂`-set is `ℤ₂`-isomorphic to an
  octahedral sphere, so `coind K` is exactly (number of antipodal orbits) `− 1` and `2(coind K + 1)`
  equals the number of vertices (`coind_eq_of_oct_iso`, `two_mul_coind_succ_eq_card`).

From the classification the **sharp join law holds for arbitrary finite nonempty free `ℤ₂`-sets**:
`coind(K ⋆ L) = coind(K) + coind(L) + 1` (`coind_join_eq_general`), with the lower bound
recovered independently and unconditionally at coindex level (`coind_join_ge`).  We also record the
**functoriality of the coindex** (`coind_mono`) and of the **join bifunctor** (`joinMap_id`,
`joinMap_comp`).

-- !-- Lab Notes -- !--
* **Hypothesis.**  The upper half of the join law was flagged as "beyond the model".  Conjecture:
  in the octahedral model the coindex is a complete invariant, so the upper half is *free*.
* **Experiment.**  Proved that every `GMap` is vertex-injective, giving a uniform Borsuk–Ulam bound
  `2(m+1) ≤ |K|`.  Combined with attainment of the supremum and an explicit equivariant bijection
  to `Oct` this pins `coind K = |K|/2 − 1`.
* **Analysis.**  "True but hidden": the obstruction dissolves because the octahedral complex on a
  free `ℤ₂`-set *is* a cross-polytope boundary, i.e. a sphere of dimension (orbits − 1).  The map
  `K ↦ coind K` is thus a faithful functor to `(ℕ, +, ·+·+1)` on finite objects.
* **Critique.**  Guarded all coindex-level statements with a vertex witness `v : K.V`: for the empty
  set the supremum is a junk value and the classification is vacuous, so nonemptiness is essential
  and is stated explicitly rather than hidden.
* **Synthesis.**  The join law becomes an identity of orbit counts; associativity/commutativity are
  inherited from `ℕ`.
-/

namespace Z2CoindexJoin

open Z2SuspensionTower Function

/-! ## Finiteness instances -/

instance instFintypeOctV (n : ℕ) : Fintype (Oct n).V := inferInstanceAs (Fintype (SVert n))

instance instFintypeJoinV (K L : FreeZ2) [Fintype K.V] [Fintype L.V] :
    Fintype (K ⋆ L).V := inferInstanceAs (Fintype (K.V ⊕ L.V))

/-- The octahedral sphere `Sⁿ` has `2(n+1)` vertices (the signed unit vectors `±e₀, …, ±eₙ`). -/
lemma card_octV (n : ℕ) : Fintype.card (Oct n).V = 2 * (n + 1) := by
  show Fintype.card (SVert n) = 2 * (n + 1)
  simp [SVert, Fintype.card_prod, Fintype.card_bool, Nat.mul_comm]

/-! ## Every ℤ₂-map is injective on vertices -/

/-- **Every `ℤ₂`-map is injective on vertices.** Equivariance turns the simpliciality condition
(no non-antipodal pair maps to an antipodal pair) into full injectivity. -/
lemma GMap.toFun_injective {K L : FreeZ2} (F : GMap K L) : Function.Injective F.toFun := by
  intro p q h
  have e1 : F.toFun q = L.anti (F.toFun (K.anti q)) := by
    have hq := F.equiv (K.anti q); rwa [K.anti_anti] at hq
  have h2 : F.toFun p = L.anti (F.toFun (K.anti q)) := by rw [h, e1]
  have h3 := F.simpl p (K.anti q) h2
  rwa [K.anti_anti] at h3

/-! ## The uniform Borsuk–Ulam bound for finite free ℤ₂-sets -/

/-- **Uniform Borsuk–Ulam bound.** If a finite free `ℤ₂`-set `K` admits an equivariant simplicial
map from the octahedral sphere `Sᵐ`, then `K` has at least `2(m+1)` vertices.  Unlike the classical
statement this holds for *every* finite free `ℤ₂`-set, not only the octahedral ones. -/
lemma gmap_card_le {K : FreeZ2} [Fintype K.V] {m : ℕ}
    (F : GMap (Oct m) K) : 2 * (m + 1) ≤ Fintype.card K.V := by
  have hinj := F.toFun_injective
  have hcard := Fintype.card_le_of_injective F.toFun hinj
  rwa [card_octV] at hcard

/-- The set of source dimensions admitting a `ℤ₂`-map into a finite `K` is bounded above. -/
lemma coind_set_bddAbove (K : FreeZ2) [Fintype K.V] :
    BddAbove {m | Nonempty (GMap (Oct m) K)} := by
  refine ⟨Fintype.card K.V, ?_⟩
  rintro m ⟨F⟩
  have := gmap_card_le F
  omega

/-! ## The coindex supremum is attained -/

/-
The `0`-sphere `S⁰ = Oct 0` maps into any nonempty free `ℤ₂`-set.
-/
lemma nonempty_gmap_Oct0 {K : FreeZ2} (v : K.V) : Nonempty (GMap (Oct 0) K) := by
  refine' ⟨ ⟨ fun p => if p.2 then v else K.anti v, _, _ ⟩ ⟩;
  · simp +decide [ Oct ];
    rw [ K.anti_anti ];
  · simp +decide [ Oct ];
    exact ⟨ by rw [ K.anti_anti ] ; exact K.anti_ne _, by exact Ne.symm ( K.anti_ne _ ) ⟩

/-- **Attainment of the coindex.** For a finite nonempty free `ℤ₂`-set the supremum defining the
coindex is achieved: there is an equivariant simplicial map `S^{coind K} → K`. -/
lemma nonempty_gmap_coind {K : FreeZ2} [Fintype K.V] (v : K.V) :
    Nonempty (GMap (Oct (coind K)) K) := by
  have hne : {m | Nonempty (GMap (Oct m) K)}.Nonempty := ⟨0, nonempty_gmap_Oct0 v⟩
  have hbdd := coind_set_bddAbove K
  have h := Nat.sSup_mem hne hbdd
  exact h

/-! ## Functoriality of the coindex -/

/-- **Monotonicity of the coindex.** A `ℤ₂`-map `K → L` (into a finite target) forces
`coind K ≤ coind L`. -/
lemma coind_mono {K L : FreeZ2} [Fintype L.V] (G : GMap K L) : coind K ≤ coind L := by
  have hsub : {m | Nonempty (GMap (Oct m) K)} ⊆ {m | Nonempty (GMap (Oct m) L)} := by
    rintro m ⟨F⟩; exact ⟨G.comp F⟩
  have hbdd := coind_set_bddAbove L
  rcases Set.eq_empty_or_nonempty {m | Nonempty (GMap (Oct m) K)} with he | hne
  · simp only [coind, he, csSup_empty]; exact bot_le
  · exact csSup_le_csSup hbdd hne hsub

/-! ## Classification of finite free ℤ₂-sets -/

/-- **Classification.** Every finite nonempty free `ℤ₂`-set is `ℤ₂`-isomorphic to an octahedral
sphere: there is an equivariant vertex bijection `K.V ≃ Sⁿ` for some `n`.  The number `n` is one
less than the number of antipodal orbits. -/
theorem exists_oct_iso (K : FreeZ2) [Fintype K.V] (v : K.V) :
    ∃ (n : ℕ) (e : K.V ≃ (Oct n).V), ∀ p, e (K.anti p) = (Oct n).anti (e p) := by
  revert v;
  intro v
  set σ := K.anti
  set r : K.V → ℕ := fun x => (Fintype.equivFin K.V x).val
  set P := Finset.filter (fun x => r x < r (σ x)) Finset.univ
  have hP_card : Finset.card P = (Fintype.card K.V) / 2 := by
    have hP_card : ∑ x ∈ Finset.univ, (if r x < r (σ x) then 1 else 0) = ∑ x ∈ Finset.univ, (if r (σ x) < r x then 1 else 0) := by
      apply Finset.sum_bij (fun x _ => σ x);
      · simp;
      · exact fun x _ y _ h => by have := K.anti_anti x; have := K.anti_anti y; aesop;
      · exact fun x _ => ⟨ σ x, Finset.mem_univ _, K.anti_anti x ⟩;
      · simp +zetaDelta at *;
        intro x; rw [ K.anti_anti ] ;
    have hP_card : ∑ x ∈ Finset.univ, (if r x < r (σ x) then 1 else 0) + ∑ x ∈ Finset.univ, (if r (σ x) < r x then 1 else 0) = Fintype.card K.V := by
      rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl fun x hx => ?_, Finset.sum_const, Finset.card_univ, smul_eq_mul, mul_one ];
      split_ifs <;> norm_num;
      · linarith;
      · exact K.anti_ne x ( Fintype.equivFin K.V |>.injective <| Fin.ext <| by linarith );
    rw [ Finset.card_filter ] ; omega;
  -- Define the equivalence $e0 : K.V \simeq P \times Bool$.
  obtain ⟨e0, he0⟩ : ∃ e0 : K.V ≃ P × Bool, ∀ p, e0 (σ p) = ((e0 p).1, ! (e0 p).2) := by
    -- Define the function $rep$ that maps each element to its representative in $P$.
    set rep : K.V → P := fun x => ⟨if r x < r (σ x) then x else σ x, by
      split_ifs <;> simp_all +decide [ P ];
      simp +zetaDelta at *;
      rw [ K.anti_anti ] ; exact lt_of_le_of_ne ‹_› ( by intro h; have := K.anti_ne x; aesop ) ;⟩
    generalize_proofs at *;
    refine' ⟨ Equiv.ofBijective ( fun x => ( rep x, decide ( r x < r ( σ x ) ) ) ) ⟨ _, _ ⟩, _ ⟩ <;> simp +decide [ Function.Injective, Function.Surjective ];
    · grind +suggestions;
    · grind +suggestions;
    · simp +zetaDelta at *;
      intro p; split_ifs <;> simp_all +decide [ K.anti_anti ] ;
      · exact lt_asymm ‹_› ‹_›;
      · exact False.elim <| K.anti_ne p <| Fintype.equivFin K.V |>.injective <| le_antisymm ‹_› ‹_›;
  obtain ⟨n, hn⟩ : ∃ n : ℕ, Fintype.card P = n + 1 := by
    refine' Nat.exists_eq_succ_of_ne_zero _;
    intro h; have := Fintype.card_congr e0; simp_all +decide ;
    exact absurd this ( Nat.ne_of_gt ( Fintype.card_pos_iff.mpr ⟨ v ⟩ ) );
  obtain ⟨φ, hφ⟩ : ∃ φ : P ≃ Fin (n + 1), True := by
    exact ⟨ Fintype.equivOfCardEq <| by simp +decide [ hn ], trivial ⟩;
  refine' ⟨ n, e0.trans ( Equiv.prodCongr φ ( Equiv.refl Bool ) ), _ ⟩ ; aesop

/-- If `K` is `ℤ₂`-isomorphic to `Sⁿ`, then `coind K = n`. -/
lemma coind_eq_of_oct_iso {K : FreeZ2} {n : ℕ} (e : K.V ≃ (Oct n).V)
    (he : ∀ p, e (K.anti p) = (Oct n).anti (e p)) : coind K = n := by
  rw [coind_congr e he, coind_Oct]

/-- **The coindex is a complete invariant.** For a finite nonempty free `ℤ₂`-set,
`2(coind K + 1)` equals the number of vertices, i.e. `coind K` is exactly (orbits `− 1`). -/
theorem two_mul_coind_succ_eq_card {K : FreeZ2} [Fintype K.V] (v : K.V) :
    2 * (coind K + 1) = Fintype.card K.V := by
  obtain ⟨n, e, he⟩ := exists_oct_iso K v
  rw [coind_eq_of_oct_iso e he, ← card_octV n, Fintype.card_congr e]

/-! ## The general join law -/

/-- **General lower bound at coindex level (unconditional, constructive).** For finite nonempty free
`ℤ₂`-sets, `coind(K ⋆ L) ≥ coind K + coind L + 1`.  This upgrades the witness-level
`coindex_join_lower_bound` to an inequality of coindices, using attainment of the supremum. -/
theorem coind_join_ge {K L : FreeZ2} [Fintype K.V] [Fintype L.V]
    (vK : K.V) (vL : L.V) :
    coind K + coind L + 1 ≤ coind (K ⋆ L) := by
  obtain ⟨F⟩ := nonempty_gmap_coind vK
  obtain ⟨G⟩ := nonempty_gmap_coind vL
  have hmem : Nonempty (GMap (Oct (coind K + coind L + 1)) (K ⋆ L)) :=
    coindex_join_lower_bound ⟨F⟩ ⟨G⟩
  have hbdd := coind_set_bddAbove (K ⋆ L)
  exact le_csSup hbdd hmem

/-- **The sharp join law, in full generality.** For arbitrary finite nonempty free `ℤ₂`-sets,
`coind(K ⋆ L) = coind K + coind L + 1`.  Both halves hold — the upper half, flagged as a
cohomological obstruction "beyond the model", follows from the classification because the coindex is
a complete invariant equal to the orbit count minus one. -/
theorem coind_join_eq_general {K L : FreeZ2} [Fintype K.V] [Fintype L.V]
    (vK : K.V) (vL : L.V) :
    coind (K ⋆ L) = coind K + coind L + 1 := by
  obtain ⟨a, eK, heK⟩ := exists_oct_iso K vK
  obtain ⟨b, eL, heL⟩ := exists_oct_iso L vL
  have hK : coind K = a := coind_eq_of_oct_iso eK heK
  have hL : coind L = b := coind_eq_of_oct_iso eL heL
  have he1 := joinEquivVert_anti eK eL heK heL
  rw [coind_congr ((joinEquivVert eK eL).trans (octJoinEquiv a b))
        (GMap.trans_equiv _ _ he1 (octJoinEquiv_anti a b)), coind_Oct, hK, hL]

/-- **Commutativity of the join-monoid, general finite case.** -/
theorem coind_join_comm_general {K L : FreeZ2} [Fintype K.V] [Fintype L.V]
    (vK : K.V) (vL : L.V) :
    coind (K ⋆ L) = coind (L ⋆ K) := by
  rw [coind_join_eq_general vK vL, coind_join_eq_general vL vK]; omega

/-- **Associativity of the join-monoid, general finite case.** -/
theorem coind_join_assoc_general {K L M : FreeZ2}
    [Fintype K.V] [Fintype L.V] [Fintype M.V] (vK : K.V) (vL : L.V) (vM : M.V) :
    coind ((K ⋆ L) ⋆ M) = coind (K ⋆ (L ⋆ M)) := by
  have h1 : coind ((K ⋆ L) ⋆ M) = (coind K + coind L + 1) + coind M + 1 := by
    rw [coind_join_eq_general (Sum.inl vK : (K ⋆ L).V) vM, coind_join_eq_general vK vL]
  have h2 : coind (K ⋆ (L ⋆ M)) = coind K + (coind L + coind M + 1) + 1 := by
    rw [coind_join_eq_general vK (Sum.inl vL : (L ⋆ M).V), coind_join_eq_general vL vM]
  omega

/-! ## Functoriality of the join bifunctor -/

/-- Two `ℤ₂`-maps agreeing on vertices are equal. -/
@[ext] lemma GMap.ext {K L : FreeZ2} {F G : GMap K L} (h : F.toFun = G.toFun) : F = G := by
  cases F; cases G; cases h; rfl

/-- **Functoriality (identity).** The join bifunctor preserves identities. -/
lemma joinMap_id (A B : FreeZ2) :
    GMap.joinMap (GMap.id A) (GMap.id B) = GMap.id (A ⋆ B) := by
  apply GMap.ext; funext p; cases p <;> rfl

/-- **Functoriality (composition).** The join bifunctor preserves composition. -/
lemma joinMap_comp {A A' B B' K L : FreeZ2}
    (F : GMap A' K) (F' : GMap A A') (G : GMap B' L) (G' : GMap B B') :
    (F.joinMap G).comp (F'.joinMap G') = (F.comp F').joinMap (G.comp G') := by
  apply GMap.ext; funext p; cases p <;> rfl

end Z2CoindexJoin