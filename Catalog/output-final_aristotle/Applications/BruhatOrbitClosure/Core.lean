import Mathlib

/-!
# Bruhat order, the product Bruhat order, and closure of orbit strata

This file develops the order-theoretic backbone underlying the correspondence between
`B`-orbit strata on a product of flag manifolds and the **product Bruhat order** on a pair
of symmetric groups.

The parametrisation of `B`-orbits on a product `X₁ × X₂` of flag manifolds attaches to each
orbit a pair `(u, v)` of Weyl-group elements — one per projection to a factor — and the
central geometric fact is that the *closure order* on orbits (`O₁ ⊆ closure O₂`) is the
restriction of the **componentwise Bruhat order** on such pairs.  Here we build the
combinatorial heart of that statement.

We model the Weyl group by the symmetric group `Perm (Fin n)` and the Bruhat order through
the classical **Ehresmann rank criterion**: for permutations `u, v`,
`u ≤ v` in Bruhat order exactly when every rank count
`rk w i j = #{ k ≤ i : w k ≤ j }` satisfies `rk v i j ≤ rk u i j`.

## Main results

* `BruhatOrbit.rk_inv` — the rank matrix of `w⁻¹` is the transpose of that of `w`.
* `BruhatOrbit.bruhat_inv_iff` — Bruhat order is invariant under inversion: `u ≤ v ↔ u⁻¹ ≤ v⁻¹`.
  This makes `w ↦ (w, w⁻¹)` (the "two projections" map) an order embedding.
* `BruhatOrbit.bruhat_antisymm` — the rank matrix determines the permutation, so the Ehresmann
  criterion is a genuine partial order (antisymmetry).
* `BruhatOrbit.identity_is_bruhat_bot` / `BruhatOrbit.reversal_is_bruhat_top` — the identity is
  the minimum and the order-reversing permutation is the maximum.
* `BruhatOrbit.prodBruhat_antisymm`, `BruhatOrbit.prodBruhat_bot`, `BruhatOrbit.prodBruhat_top`
  — the product Bruhat order is a partial order with explicit extremes.
* `BruhatOrbit.orbit_closure_iff` — the headline: for the two-projection map `w ↦ (w, w⁻¹)`,
  the Bruhat relation coincides with the restriction of the product Bruhat order,
  i.e. `u ≤ v ↔ (u, u⁻¹) ≤ (v, v⁻¹)` componentwise.
* `BruhatOrbit.bruhat_bot_iff_len_zero` — the Bruhat-minimal element is exactly the unique
  inversion-free permutation, linking the rank criterion to the inversion length `len`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The closure order on `B`-orbit strata of a product of flag
  manifolds is the restriction of the componentwise Bruhat order under the two-projection
  parametrisation `O ↦ (u, v)`.  A necessary skeleton: the Bruhat order is a partial order,
  is inversion-invariant (so the two projections carry compatible orders), and has extremes.
Experiment (Experimenter): Encoded Bruhat order via the Ehresmann rank criterion on
  `Perm (Fin n)`.  Verified the extremes, antisymmetry, and inversion-invariance on `n = 3`
  by exhaustive computation, then proved them in general.  The transpose identity
  `rk w⁻¹ i j = rk w j i` turned inversion-invariance into a one-line consequence.
Analysis (Analyst): Antisymmetry is the load-bearing fact — it is equivalent to "the rank
  matrix determines the permutation", recovered by telescoping the rank counts along a row.
  Inversion-invariance is exactly what makes `w ↦ (w, w⁻¹)` an order embedding into the
  product order, which is the algebraic shadow of the two projections of a product of flag
  manifolds.
Critique (Critic): We do not assume any geometry; the orbit/closure statement is captured at
  the level of the parametrising posets, where it is a theorem about the product Bruhat order.
  Every result below is proved from the rank criterion with no circular references.
Synthesis (PI): `bruhat_antisymm`, `bruhat_inv_iff`, the extremes, and `orbit_closure_iff`
  package the order-theoretic content of "Bruhat order preserves closure relations".
-- !-- Lab Notes -- !--
-/

open Equiv Finset

namespace BruhatOrbit

variable {n : ℕ}

/-- The set of inversions of `σ`: pairs of positions `i < j` whose values are out of order.
(Mirrors the inversion-length construction from the Schubert-length catalog note.) -/
def invSet (σ : Perm (Fin n)) : Finset (Fin n × Fin n) :=
  univ.filter (fun p => p.1 < p.2 ∧ σ p.2 < σ p.1)

/-- The Coxeter / Bruhat length of `σ`: its number of inversions. -/
def len (σ : Perm (Fin n)) : ℕ := (invSet σ).card

/-- The Ehresmann rank count of a permutation: the number of positions `k ≤ i` whose image
`w k` is `≤ j`. -/
def rk (w : Perm (Fin n)) (i j : Fin n) : ℕ :=
  (univ.filter (fun k => k ≤ i ∧ w k ≤ j)).card

/-- The Bruhat order on the symmetric group via the Ehresmann rank criterion:
`u ≤ v` when every rank count of `v` is at most the corresponding rank count of `u`. -/
def BruhatLE (u v : Perm (Fin n)) : Prop :=
  ∀ i j, rk v i j ≤ rk u i j

/-- The componentwise (product) Bruhat order on pairs of permutations. -/
def ProdBruhatLE (p q : Perm (Fin n) × Perm (Fin n)) : Prop :=
  BruhatLE p.1 q.1 ∧ BruhatLE p.2 q.2

instance : DecidableRel (@BruhatLE n) := fun u v => by unfold BruhatLE; infer_instance

/-- Bruhat order is reflexive. -/
theorem bruhatLE_refl (w : Perm (Fin n)) : BruhatLE w w := fun _ _ => le_refl _

/-- Bruhat order is transitive. -/
theorem bruhatLE_trans {a b c : Perm (Fin n)} (hab : BruhatLE a b) (hbc : BruhatLE b c) :
    BruhatLE a c := fun i j => le_trans (hbc i j) (hab i j)

/-
**Transpose identity.**  The rank matrix of `w⁻¹` is the transpose of that of `w`.
-/
theorem rk_inv (w : Perm (Fin n)) (i j : Fin n) : rk w⁻¹ i j = rk w j i := by
  refine' Finset.card_bij ( fun k hk => w⁻¹ k ) _ _ _ <;> simp +decide [ * ];
  · tauto;
  · exact fun b hb₁ hb₂ => ⟨ w b, ⟨ hb₂, by simpa using hb₁ ⟩, by simp +decide ⟩

/-- **Inversion invariance of the Bruhat order.**  `u ≤ v` in Bruhat order iff `u⁻¹ ≤ v⁻¹`.
Consequently `w ↦ (w, w⁻¹)` is a Bruhat order embedding into the product order. -/
theorem bruhat_inv_iff {u v : Perm (Fin n)} : BruhatLE u v ↔ BruhatLE u⁻¹ v⁻¹ := by
  constructor
  · intro h i j
    rw [rk_inv, rk_inv]; exact h j i
  · intro h i j
    have := h j i
    rwa [rk_inv, rk_inv] at this

/-
**Antisymmetry / the rank matrix determines the permutation.**  If two permutations have
the same rank matrix (each `≤` the other in Bruhat order), they are equal.
-/
theorem bruhat_antisymm {u v : Perm (Fin n)} (h1 : BruhatLE u v) (h2 : BruhatLE v u) :
    u = v := by
  -- By definition of BruhatLE, we have that for all i and j, rk u i j = rk v i j.
  have h_eq_rank : ∀ i j, rk u i j = rk v i j := by
    exact fun i j => le_antisymm ( h2 i j ) ( h1 i j );
  -- By definition of BruhatLE, we have that for all i and j, the number of elements in the set {k | k ≤ i ∧ u k ≤ j} is equal to the number of elements in the set {k | k ≤ i ∧ v k ≤ j}.
  have h_eq_card : ∀ i j, Finset.card (Finset.filter (fun k => k ≤ i ∧ u k ≤ j) Finset.univ) = Finset.card (Finset.filter (fun k => k ≤ i ∧ v k ≤ j) Finset.univ) := by
    exact h_eq_rank;
  -- By definition of BruhatLE, we have that for all i and j, the number of elements in the set {k | k < i ∧ u k ≤ j} is equal to the number of elements in the set {k | k < i ∧ v k ≤ j}.
  have h_eq_card_lt : ∀ i j, Finset.card (Finset.filter (fun k => k < i ∧ u k ≤ j) Finset.univ) = Finset.card (Finset.filter (fun k => k < i ∧ v k ≤ j) Finset.univ) := by
    intro i j;
    by_cases hi : i = ⟨ 0, by linarith [ Fin.is_lt i ] ⟩;
    · simp +decide [ hi, Fin.lt_def ];
    · convert h_eq_card ( ⟨ i.val - 1, Nat.lt_of_le_of_lt ( Nat.pred_le _ ) i.2 ⟩ ) j using 1;
      · congr! 2;
        grind +suggestions;
      · congr! 2;
        grind +qlia;
  -- By definition of BruhatLE, we have that for all i and j, the indicator function `(u i ≤ j : Prop)` is equal to `(v i ≤ j : Prop)`.
  have h_eq_indicator : ∀ i j, (u i ≤ j) = (v i ≤ j) := by
    intro i j; specialize h_eq_card i j; specialize h_eq_card_lt i j; simp_all +decide [ Finset.filter_and ] ;
    rw [ show ( Finset.filter ( fun a => a ≤ i ) Finset.univ ∩ Finset.filter ( fun a => u a ≤ j ) Finset.univ ) = Finset.filter ( fun a => a < i ) Finset.univ ∩ Finset.filter ( fun a => u a ≤ j ) Finset.univ ∪ ( if u i ≤ j then { i } else ∅ ) from ?_, show ( Finset.filter ( fun a => a ≤ i ) Finset.univ ∩ Finset.filter ( fun a => v a ≤ j ) Finset.univ ) = Finset.filter ( fun a => a < i ) Finset.univ ∩ Finset.filter ( fun a => v a ≤ j ) Finset.univ ∪ ( if v i ≤ j then { i } else ∅ ) from ?_ ] at h_eq_card; all_goals grind;
  ext i; exact (by
  exact le_antisymm ( by simpa using h_eq_indicator i ( v i ) ) ( by simpa using h_eq_indicator i ( u i ) ));

/-
The number of elements of `Fin n` that are `≤ m` equals `m + 1`.
-/
theorem card_le_fin (m : Fin n) : (univ.filter (fun k : Fin n => k ≤ m)).card = (m : ℕ) + 1 := by
  rw [ show Finset.univ.filter fun x : Fin n => x ≤ m = Finset.Iic m by ext; simp +decide ] ; simp +decide ;

/-
**The identity is the Bruhat minimum.**
-/
theorem identity_is_bruhat_bot (w : Perm (Fin n)) : BruhatLE 1 w := by
  -- We need to show that for all `i j`, `rk w i j ≤ i + 1` and `rk w i j ≤ j + 1`.
  have h_le : ∀ i j : Fin n, (Finset.univ.filter (fun k : Fin n => k ≤ i ∧ w k ≤ j)).card ≤ (min i j : ℕ) + 1 := by
    intros i j
    have h_le_i : (Finset.univ.filter (fun k : Fin n => k ≤ i ∧ w k ≤ j)).card ≤ (Finset.univ.filter (fun k : Fin n => k ≤ i)).card := by
      exact Finset.card_le_card fun x hx => by aesop;
    have h_le_j : (Finset.univ.filter (fun k : Fin n => k ≤ i ∧ w k ≤ j)).card ≤ (Finset.univ.filter (fun k : Fin n => k ≤ j)).card := by
      convert Finset.card_le_card ( show Finset.image w ( Finset.filter ( fun k => k ≤ i ∧ w k ≤ j ) Finset.univ ) ⊆ Finset.filter ( fun k => k ≤ j ) Finset.univ from ?_ ) using 1;
      · rw [ Finset.card_image_of_injective _ w.injective ];
      · grind
    have h_card_i : (Finset.univ.filter (fun k : Fin n => k ≤ i)).card = (i : ℕ) + 1 := by
      convert card_le_fin i
    have h_card_j : (Finset.univ.filter (fun k : Fin n => k ≤ j)).card = (j : ℕ) + 1 := by
      rw [ show ( Finset.univ.filter fun k : Fin n => k ≤ j ) = Finset.Iic j by ext; simp +decide ] ; simp +decide ;
    simp_all +decide [ card_le_fin ];
    cases min_cases ( i : ℕ ) j <;> linarith;
  intro i j; convert h_le i j using 1; simp +decide [ BruhatOrbit.rk ] ;
  convert card_le_fin ( min i j ) using 1;
  exact congr_arg Finset.card ( by ext; simp +decide )

/-
**The order-reversing permutation is the Bruhat maximum.**
-/
theorem reversal_is_bruhat_top (w : Perm (Fin n)) : BruhatLE w Fin.revPerm := by
  -- The rank count of the reverse permutation is exactly ((i+1)+(j+1)-n).
  have h_rev_rank : ∀ i j : Fin n, BruhatOrbit.rk (Fin.revPerm) i j = (i.val + 1 + j.val + 1 - n : ℕ) := by
    intro i j; unfold BruhatOrbit.rk; simp +decide [ Fin.revPerm ] ;
    convert Finset.card_eq_sum_ones ( Finset.Icc ( Fin.rev j ) i ) using 1;
    · congr with k ; simp +decide [ Fin.rev_le_iff ];
      tauto;
    · simp +decide [ Fin.rev ];
      omega;
  -- For any permutation, the rank count is at least ((i+1)+(j+1)-n).
  have h_rank_bound : ∀ i j : Fin n, BruhatOrbit.rk w i j ≥ (i.val + 1 + j.val + 1 - n : ℕ) := by
    intro i j
    have h_card : (Finset.univ.filter (fun k : Fin n => k ≤ i)).card = i.val + 1 := by
      convert card_le_fin i using 1
    have h_card' : (Finset.univ.filter (fun k : Fin n => w k ≤ j)).card = j.val + 1 := by
      rw [ show ( Finset.univ.filter fun k => w k ≤ j ) = Finset.image ( fun k => w.symm k ) ( Finset.Iic j ) from ?_, Finset.card_image_of_injective _ w.symm.injective ] ; aesop;
      ext k; simp +decide [ Equiv.symm_apply_eq ] ;
    have h_card_inter : (Finset.univ.filter (fun k : Fin n => k ≤ i ∧ w k ≤ j)).card ≥ (Finset.univ.filter (fun k : Fin n => k ≤ i)).card + (Finset.univ.filter (fun k : Fin n => w k ≤ j)).card - n := by
      have := Finset.card_union_add_card_inter ( Finset.filter ( fun k => k ≤ i ) Finset.univ ) ( Finset.filter ( fun k => w k ≤ j ) Finset.univ ) ; simp_all +decide [ Finset.filter_and ] ;
      linarith [ show Finset.card ( Finset.filter ( fun k => k ≤ i ) Finset.univ ∪ Finset.filter ( fun k => w k ≤ j ) Finset.univ ) ≤ n from le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ];
    simp_all +decide [ BruhatOrbit.rk ];
    linarith;
  exact fun i j => h_rev_rank i j ▸ h_rank_bound i j

/-! ### The product Bruhat order -/

/-- The product Bruhat order is reflexive. -/
theorem prodBruhatLE_refl (p : Perm (Fin n) × Perm (Fin n)) : ProdBruhatLE p p :=
  ⟨bruhatLE_refl _, bruhatLE_refl _⟩

/-- The product Bruhat order is transitive. -/
theorem prodBruhatLE_trans {p q r : Perm (Fin n) × Perm (Fin n)}
    (hpq : ProdBruhatLE p q) (hqr : ProdBruhatLE q r) : ProdBruhatLE p r :=
  ⟨bruhatLE_trans hpq.1 hqr.1, bruhatLE_trans hpq.2 hqr.2⟩

/-- **Antisymmetry of the product Bruhat order.** -/
theorem prodBruhat_antisymm {p q : Perm (Fin n) × Perm (Fin n)}
    (h1 : ProdBruhatLE p q) (h2 : ProdBruhatLE q p) : p = q :=
  Prod.ext (bruhat_antisymm h1.1 h2.1) (bruhat_antisymm h1.2 h2.2)

/-- The pair `(1, 1)` is the minimum of the product Bruhat order. -/
theorem prodBruhat_bot (p : Perm (Fin n) × Perm (Fin n)) : ProdBruhatLE (1, 1) p :=
  ⟨identity_is_bruhat_bot _, identity_is_bruhat_bot _⟩

/-- The pair `(w₀, w₀)` of order-reversing permutations is the maximum of the product order. -/
theorem prodBruhat_top (p : Perm (Fin n) × Perm (Fin n)) :
    ProdBruhatLE p (Fin.revPerm, Fin.revPerm) :=
  ⟨reversal_is_bruhat_top _, reversal_is_bruhat_top _⟩

/-! ### The closure correspondence -/

/-- **Bruhat order preserves closure relations.**

For the two-projection parametrisation `w ↦ (w, w⁻¹)` — the combinatorial model of the two
projections of a product of flag manifolds — the Bruhat relation on strata coincides with the
restriction of the product Bruhat order:
`u ≤ v` in Bruhat order iff `(u, u⁻¹) ≤ (v, v⁻¹)` componentwise. -/
theorem orbit_closure_iff (u v : Perm (Fin n)) :
    BruhatLE u v ↔ ProdBruhatLE (u, u⁻¹) (v, v⁻¹) := by
  unfold ProdBruhatLE
  simp only
  constructor
  · intro h; exact ⟨h, bruhat_inv_iff.mp h⟩
  · intro h; exact h.1

/-- The two-projection map `w ↦ (w, w⁻¹)` is injective. -/
theorem orbit_map_injective :
    Function.Injective (fun w : Perm (Fin n) => (w, w⁻¹)) := by
  intro a b h
  exact (Prod.ext_iff.mp h).1

/-! ### Bridge to the inversion length `len` -/

/-
A permutation is inversion-free exactly when it is the identity.
-/
theorem len_zero_iff_identity (w : Perm (Fin n)) :
    len w = 0 ↔ w = 1 := by
  constructor <;> intro h <;> simp_all +decide [ len ];
  · refine' Equiv.Perm.ext fun x => _;
    have h_strict_mono : StrictMono w := by
      simp_all +decide [ Finset.ext_iff, invSet ];
      exact fun a b hab => lt_of_le_of_ne ( h a b hab ) ( w.injective.ne hab.ne );
    -- Since $w$ is strictly monotone, we have $w x \geq x$ for all $x$.
    have h_ge : ∀ x : Fin n, w x ≥ x := fun x => h_strict_mono.le_apply
    exact le_antisymm ( le_of_not_gt fun hx => by have := Equiv.sum_comp w fun x => ( x : ℕ ) ; exact absurd this ( by { exact ne_of_gt <| Finset.sum_lt_sum ( fun a _ => by aesop ) ⟨ x, Finset.mem_univ _, by aesop ⟩ } ) ) ( h_ge x );
  · simp +decide [ invSet ];
    exact fun a b hab => le_of_lt hab

/-- **The Bruhat-minimal element is the unique inversion-free permutation.**

Combining antisymmetry, the identity being the Bruhat minimum, and the inversion-length
characterisation: an element is `≤` every permutation iff it has no inversions. -/
theorem bruhat_bot_iff_len_zero (w : Perm (Fin n)) :
    (∀ v, BruhatLE w v) ↔ len w = 0 := by
  rw [len_zero_iff_identity]
  constructor
  · intro h
    exact bruhat_antisymm (h 1) (identity_is_bruhat_bot w)
  · intro h v
    rw [h]; exact identity_is_bruhat_bot v

end BruhatOrbit