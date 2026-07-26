import Mathlib

/-!
# Tropical Proof-Valuation Duality

This file establishes a structural duality between proof theory and tropical (min-plus)
algebra: **finite derivability in weighted proof systems is characterized by a fixed point
of a min-plus consequence operator, and optimal derivations are reconstructible from
this fixed-point data**.

## Main Results

* `consequenceOp_monotone` — The consequence operator is monotone on the complete lattice
  of valuations `P → ℕ∞`.
* `fixedPoint_le_derivCost` — Any fixed point of the consequence operator provides a lower
  bound on all derivation costs (soundness).
* `minDerivCost_fixed_point` — The minimal derivation cost function is a fixed point of
  the consequence operator (Bellman optimality).
* `minDerivCost_greatest_fixedPoint` — The minimal derivation cost function is the greatest
  fixed point: it dominates every other fixed point.
* `exists_optimal_derivation` — For every derivable proposition, the minimum cost is attained
  by some concrete derivation (certified reconstruction).
* `tropical_proof_valuation_duality` — The main duality theorem packaging all results.
-/

open List WithTop

namespace TropicalProofValuationDuality

/-! ## §1. Cost Domain and Basic Structures -/

/-- The cost domain: extended natural numbers `ℕ∞ = WithTop ℕ`.
    `⊤` represents infinite cost (underivable). -/
abbrev Cost := ℕ∞

/-- A weighted inference rule: premises, conclusion, and weight. -/
structure WeightedRule (P : Type*) where
  premises : List P
  conclusion : P
  weight : ℕ
  deriving DecidableEq

/-- A weighted proof system: rules plus axiom designation. -/
structure WeightedProofSystem (P : Type*) where
  rules : List (WeightedRule P)
  isAxiom : P → Bool

variable {P : Type*} [DecidableEq P]

/-! ## §2. Derivations -/

/-- `HasDeriv S q n` states that `q` is derivable in `S` with total cost `n`.

    Uses explicit indexing (rather than `List.Forall₂`) so that Lean generates
    an induction principle with usable IH for sub-derivations. -/
inductive HasDeriv (S : WeightedProofSystem P) : P → ℕ → Prop where
  | ax (q : P) : S.isAxiom q = true → HasDeriv S q 0
  | step (r : WeightedRule P) (costs : List ℕ) :
      r ∈ S.rules →
      r.premises.length = costs.length →
      (∀ (i : ℕ) (hi : i < r.premises.length) (hi2 : i < costs.length),
        HasDeriv S (r.premises[i]) (costs[i])) →
      HasDeriv S r.conclusion (r.weight + costs.sum)

/-- A proposition is *derivable* if it has some derivation of finite cost. -/
def Derivable (S : WeightedProofSystem P) (q : P) : Prop :=
  ∃ n, HasDeriv S q n

/-- The minimal derivation cost: infimum of all derivation costs.
    Equals `⊤` if `q` is not derivable. -/
noncomputable def minDerivCost (S : WeightedProofSystem P) (q : P) : Cost :=
  ⨅ (n : ℕ) (_ : HasDeriv S q n), (n : Cost)

/-! ## §3. Consequence Operator -/

/-- Cost of applying a rule given valuation `f` on premises. -/
def ruleCost (f : P → Cost) (r : WeightedRule P) : Cost :=
  (r.weight : Cost) + (r.premises.map f).sum

/-- The one-step consequence operator.
    `T(f)(q) = min(axiomCost(q), inf over rules r concluding q of ruleCost(f, r))` -/
noncomputable def consequenceOp (S : WeightedProofSystem P) (f : P → Cost) (q : P) : Cost :=
  (if S.isAxiom q then (0 : Cost) else ⊤) ⊓
  (⨅ (r : WeightedRule P) (_ : r ∈ S.rules) (_ : r.conclusion = q), ruleCost f r)

/-! ## §4. Monotonicity -/

/-
Sum of a mapped list is monotone w.r.t. pointwise ordering.
-/
theorem list_sum_le_of_forall_le {l : List P} {f g : P → Cost}
    (h : ∀ p ∈ l, f p ≤ g p) :
    (l.map f).sum ≤ (l.map g).sum := by
  convert List.sum_le_sum fun x hx => h x hx

/-
`ruleCost` is monotone in the valuation.
-/
theorem ruleCost_monotone {f g : P → Cost} (hfg : f ≤ g)
    (r : WeightedRule P) : ruleCost f r ≤ ruleCost g r := by
  apply_rules [ add_le_add, list_sum_le_of_forall_le ];
  · rfl;
  · exact fun p hp => hfg p

/-
**The consequence operator is monotone.**
-/
theorem consequenceOp_monotone (S : WeightedProofSystem P) :
    Monotone (consequenceOp S) := by
  -- Apply the definition of `consequenceOp` and use the fact that infimum is monotone.
  unfold consequenceOp; intro f g hfg; simp [hfg];
  refine' fun q => min_le_min le_rfl ( iInf_mono fun r => iInf_mono fun hr => iInf_mono fun hq => ruleCost_monotone hfg r )

/-! ## §5. Soundness: Fixed Points Bound Derivation Costs -/

/-
Helper: if each element of a list of ℕ∞ is ≤ the corresponding ℕ cast,
    then the sum is ≤ the cast of the ℕ sum.
-/
theorem list_map_sum_le_natCast {prems : List P} {costs : List ℕ}
    {f : P → Cost}
    (hlen : prems.length = costs.length)
    (hle : ∀ (i : ℕ) (hi : i < prems.length) (hi2 : i < costs.length),
      f (prems[i]) ≤ ↑(costs[i])) :
    (prems.map f).sum ≤ ↑(costs.sum) := by
  have h_prems : ∀ (prems : List P) (costs : List ℕ), prems.length = costs.length → (∀ i (hi : i < prems.length) (hi2 : i < costs.length), f prems[i] ≤ costs[i]) → (List.map f prems).sum ≤ costs.sum := by
    intros prems costs hlen hle; induction' prems with p prems ih generalizing costs <;> simp_all +decide [ List.sum_cons ] ;
    rcases costs with ( _ | ⟨ c, costs ⟩ ) <;> simp_all +decide [ List.length ];
    exact add_le_add ( hle 0 bot_le ) ( ih costs rfl fun i hi => hle ( i + 1 ) ( by linarith ) );
  exact h_prems prems costs hlen hle

/-
**Soundness**: if `f` is a fixed point, then `f(q) ≤ n` for every derivation
    of `q` with cost `n`. Proved by induction on derivations.
-/
theorem fixedPoint_le_derivCost (S : WeightedProofSystem P)
    (f : P → Cost) (hf : ∀ q, consequenceOp S f q = f q) :
    ∀ (q : P) (n : ℕ), HasDeriv S q n → f q ≤ ↑n := by
  intro q n h;
  induction' h with q hq h ih generalizing f;
  · exact hf q ▸ by simp +decide [ consequenceOp, hq ] ;
  · rw [ ← hf ];
    refine' le_trans ( inf_le_right ) _;
    refine' le_trans ( ciInf_le _ h ) _;
    · simp +zetaDelta at *;
    · simp +decide [ *, ruleCost ];
      convert list_map_sum_le_natCast _ _ <;> aesop

/-
Any fixed point is pointwise ≤ `minDerivCost`.
-/
theorem fixedPoint_le_minDerivCost (S : WeightedProofSystem P)
    (f : P → Cost) (hf : ∀ q, consequenceOp S f q = f q) :
    ∀ q, f q ≤ minDerivCost S q := by
  refine' fun q => le_iInf₂ fun n hn => fixedPoint_le_derivCost S f hf q n hn

/-! ## §6. Completeness: minDerivCost Is a Fixed Point -/

/-
`T(minDerivCost) ≤ minDerivCost` pointwise.
-/
theorem consequenceOp_minDerivCost_le (S : WeightedProofSystem P) :
    ∀ q, consequenceOp S (minDerivCost S) q ≤ minDerivCost S q := by
  intro q
  unfold consequenceOp;
  refine' le_iInf₂ fun n hn => _;
  induction' hn with q hax q r costs hr hlen hprems;
  · aesop;
  · refine' le_trans ( min_le_right _ _ ) ( le_trans ( ciInf_le _ q ) _ );
    · exact ⟨ 0, Set.forall_mem_range.2 fun r => zero_le _ ⟩;
    · simp +decide [ costs, ruleCost ];
      convert list_map_sum_le_natCast hr _;
      · induction r <;> simp +decide [ * ];
      · intro i hi hi2;
        exact ciInf_le_of_le ⟨ 0, Set.forall_mem_range.2 fun _ => zero_le _ ⟩ _ ( ciInf_le ⟨ 0, Set.forall_mem_range.2 fun _ => zero_le _ ⟩ ( hlen i hi hi2 ) )

/-
`minDerivCost ≤ T(minDerivCost)` pointwise.
-/
theorem minDerivCost_le_consequenceOp (S : WeightedProofSystem P) :
    ∀ q, minDerivCost S q ≤ consequenceOp S (minDerivCost S) q := by
  unfold minDerivCost consequenceOp;
  intro q
  by_cases h_axiom : S.isAxiom q = true;
  · simp +decide [ h_axiom ];
    exact HasDeriv.ax q h_axiom;
  · simp +decide [ h_axiom ];
    intro r hr hq
    by_cases h_ruleCost : ruleCost (fun q => ⨅ n, ⨅ (_ : HasDeriv S q n), (n : Cost)) r = ⊤;
    · exact h_ruleCost.symm ▸ le_top;
    · -- Since `ruleCost (fun q => ⨅ n, ⨅ (_ : HasDeriv S q n), (n : Cost)) r ≠ ⊤`, each premise of `r` has a finite minimal derivation cost.
      have h_premises_finite : ∀ p ∈ r.premises, ∃ n, HasDeriv S p n ∧ ⨅ n, ⨅ (_ : HasDeriv S p n), (n : Cost) = n := by
        intro p hp
        have h_premise_finite : ⨅ n, ⨅ (_ : HasDeriv S p n), (n : Cost) ≠ ⊤ := by
          contrapose! h_ruleCost;
          exact le_antisymm ( le_top ) ( le_add_of_nonneg_of_le ( Nat.cast_nonneg _ ) ( List.le_sum_of_mem ( List.mem_map.mpr ⟨ p, hp, h_ruleCost ⟩ ) ) );
        obtain ⟨n, hn⟩ : ∃ n, HasDeriv S p n := by
          contrapose! h_premise_finite; aesop;
        have := Nat.sInf_mem ( show { n : ℕ | HasDeriv S p n }.Nonempty from ⟨ n, hn ⟩ );
        refine' ⟨ _, this, le_antisymm _ _ ⟩;
        · exact ciInf_le_of_le ⟨ 0, Set.forall_mem_range.2 fun _ => zero_le _ ⟩ _ ( ciInf_le ⟨ 0, Set.forall_mem_range.2 fun _ => zero_le _ ⟩ this );
        · refine' le_iInf fun n => le_iInf fun hn => _;
          exact_mod_cast Nat.sInf_le hn;
      choose! n hn hn' using h_premises_finite;
      refine' le_trans ( ciInf_le _ ( r.weight + List.sum ( List.map n r.premises ) ) ) _;
      · exact ⟨ 0, Set.forall_mem_range.2 fun n => zero_le _ ⟩;
      · refine' le_trans ( ciInf_le _ _ ) _;
        · exact ⟨ 0, Set.forall_mem_range.2 fun _ => Nat.cast_nonneg _ ⟩;
        · convert HasDeriv.step r ( List.map n r.premises ) hr _ _ using 1;
          · exact hq.symm;
          · rw [ List.length_map ];
          · aesop;
        · unfold ruleCost;
          rw [ List.map_congr_left fun p hp => hn' p hp ] ; simp +decide [ add_comm ];
          exact le_of_eq ( add_comm _ _ )

/-- **Bellman optimality**: `minDerivCost` is a fixed point of `T`. -/
theorem minDerivCost_fixed_point (S : WeightedProofSystem P) :
    ∀ q, consequenceOp S (minDerivCost S) q = minDerivCost S q :=
  fun q => le_antisymm (consequenceOp_minDerivCost_le S q) (minDerivCost_le_consequenceOp S q)

/-- **Greatest fixed point**: `minDerivCost` dominates every other fixed point. -/
theorem minDerivCost_greatest_fixedPoint (S : WeightedProofSystem P) :
    (∀ q, consequenceOp S (minDerivCost S) q = minDerivCost S q) ∧
    (∀ f : P → Cost, (∀ q, consequenceOp S f q = f q) → ∀ q, f q ≤ minDerivCost S q) :=
  ⟨minDerivCost_fixed_point S, fixedPoint_le_minDerivCost S⟩

/-! ## §7. Certified Reconstruction -/

/-
**Certified reconstruction**: for every derivable `q`, the minimum cost is attained.
-/
theorem exists_optimal_derivation (S : WeightedProofSystem P) (q : P)
    (hq : Derivable S q) :
    ∃ n, HasDeriv S q n ∧ minDerivCost S q = ↑n := by
  obtain ⟨ n, hn ⟩ := hq;
  have h_inf : minDerivCost S q ≠ ⊤ := by
    exact ne_of_lt ( lt_of_le_of_lt ( ciInf_le ⟨ 0, Set.forall_mem_range.2 fun _ => zero_le _ ⟩ n ) ( lt_of_le_of_lt ( ciInf_le ⟨ 0, Set.forall_mem_range.2 fun _ => zero_le _ ⟩ hn ) ( WithTop.coe_lt_top _ ) ) );
  obtain ⟨ m, hm ⟩ := WithTop.ne_top_iff_exists.mp h_inf;
  have h_inf : ∃ n, HasDeriv S q n ∧ n ≤ m := by
    contrapose! hm;
    refine' ne_of_lt ( lt_of_lt_of_le ( WithTop.coe_lt_coe.mpr ( Nat.lt_succ_self m ) ) _ );
    exact le_iInf₂ fun n hn => Nat.cast_le.mpr ( Nat.succ_le_of_lt ( hm n hn ) );
  obtain ⟨ n, hn₁, hn₂ ⟩ := h_inf;
  exact ⟨ n, hn₁, le_antisymm ( by exact ciInf_le_of_le ⟨ 0, Set.forall_mem_range.2 fun _ => zero_le _ ⟩ n ( by aesop ) ) ( by exact hm ▸ Nat.cast_le.2 hn₂ ) ⟩

/-
Non-derivable propositions have cost `⊤`.
-/
theorem minDerivCost_top_of_not_derivable (S : WeightedProofSystem P) (q : P)
    (hq : ¬Derivable S q) :
    minDerivCost S q = ⊤ := by
  exact iInf_eq_top.mpr fun n => iInf_eq_top.mpr fun hn => False.elim <| hq ⟨ n, hn ⟩

/-! ## §8. Main Duality Theorem -/

/-- **Tropical Proof-Valuation Duality Theorem.**

    For any weighted proof system:
    1. `minDerivCost` is a fixed point of the consequence operator (Bellman equation).
    2. `minDerivCost` is the greatest fixed point (dominates all others).
    3. For derivable propositions, the minimum cost is attained (certified reconstruction).

    This establishes that **proof cost and proof existence are fully determined by
    tropical algebraic fixed-point structure**. -/
theorem tropical_proof_valuation_duality (S : WeightedProofSystem P) :
    (∀ q, consequenceOp S (minDerivCost S) q = minDerivCost S q) ∧
    (∀ f : P → Cost, (∀ q, consequenceOp S f q = f q) → ∀ q, f q ≤ minDerivCost S q) ∧
    (∀ q, Derivable S q → ∃ n, HasDeriv S q n ∧ minDerivCost S q = ↑n) :=
  ⟨minDerivCost_fixed_point S,
   fun f hf => fixedPoint_le_minDerivCost S f hf,
   exists_optimal_derivation S⟩

/-! ## §9. Extremal Valuations and Prime Templates -/

/-- A valuation is *realizable* if every finite cost is witnessed by a derivation. -/
def IsRealizableValuation (S : WeightedProofSystem P) (v : P → Cost) : Prop :=
  ∀ q (n : ℕ), v q = ↑n → HasDeriv S q n

/-- A realizable valuation is *extremal*: it cannot be decomposed as the pointwise
    minimum of two strictly larger realizable valuations. -/
def IsExtremal (S : WeightedProofSystem P) (v : P → Cost) : Prop :=
  IsRealizableValuation S v ∧
  ∀ v₁ v₂ : P → Cost, IsRealizableValuation S v₁ → IsRealizableValuation S v₂ →
    (∀ q, v q = v₁ q ⊓ v₂ q) → v₁ = v ∨ v₂ = v

/-- A derivation template is *prime*: every proposition with finite cost is
    directly justified by an axiom or a rule whose premises all have finite cost. -/
def IsPrimeTemplate (S : WeightedProofSystem P) (v : P → Cost) : Prop :=
  IsRealizableValuation S v ∧
  ∀ q, v q < ⊤ → (S.isAxiom q = true ∨
    ∃ r ∈ S.rules, r.conclusion = q ∧ ∀ p ∈ r.premises, v p < ⊤)

/-
`minDerivCost` is itself a realizable valuation.
-/
theorem minDerivCost_realizable (S : WeightedProofSystem P) :
    IsRealizableValuation S (minDerivCost S) := by
  intro q n hn;
  have := exists_optimal_derivation S q;
  by_cases h : Derivable S q <;> simp_all +decide;
  exact absurd hn ( by rw [ minDerivCost_top_of_not_derivable S q h ] ; simp +decide )

/-
`minDerivCost` is a prime template.
-/
theorem minDerivCost_isPrimeTemplate (S : WeightedProofSystem P) :
    IsPrimeTemplate S (minDerivCost S) := by
  refine' ⟨ minDerivCost_realizable S, _ ⟩;
  intro q hq
  obtain ⟨n, hn⟩ : ∃ n, HasDeriv S q n ∧ minDerivCost S q = n := by
    apply exists_optimal_derivation;
    contrapose! hq; simp_all +decide [ minDerivCost_top_of_not_derivable ] ;
  cases' hn.1 with r hr;
  · exact Or.inl hr;
  · rename_i r costs hr₁ hr₂ hr₃;
    refine' Or.inr ⟨ r, hr₁, rfl, fun p hp => _ ⟩;
    obtain ⟨ i, hi ⟩ := List.mem_iff_get.1 hp;
    exact lt_of_le_of_lt ( fixedPoint_le_derivCost S _ ( minDerivCost_fixed_point S ) _ _ ( hr₃ _ i.2 ( by simpa [ hr₂ ] using i.2 ) ) ) ( WithTop.coe_lt_top _ ) |> fun h => by aesop;

/-! ## §10. Concrete Examples -/

/-- Example system on `Fin 3`:
    * Proposition 0 is an axiom
    * Rule: {0} ⊢ 1 (weight 3)
    * Rule: {0, 1} ⊢ 2 (weight 2) -/
def exampleSystem : WeightedProofSystem (Fin 3) where
  rules := [⟨[0], 1, 3⟩, ⟨[0, 1], 2, 2⟩]
  isAxiom := fun p => p == 0

theorem example_deriv_0 : HasDeriv exampleSystem 0 0 :=
  HasDeriv.ax 0 rfl

theorem example_deriv_1 : HasDeriv exampleSystem 1 3 := by
  convert HasDeriv.step _ [ 0 ] _ _ _ <;> norm_num;
  rotate_left;
  rotate_left;
  exact ⟨ [ 0 ], 1, 3 ⟩;
  · exact List.mem_cons_self;
  · rfl;
  · exact fun i hi hi' => by subst hi'; exact example_deriv_0;
  · rfl;
  · rfl

theorem example_deriv_2 : HasDeriv exampleSystem 2 5 := by
  apply HasDeriv.step ⟨[0, 1], 2, 2⟩ [0, 3] (by
  exact?) (by
  rfl) (by
  rintro ( _ | _ | i ) <;> simp +arith +decide;
  · exact HasDeriv.ax _ rfl;
  · exact?)

/-
All three propositions are derivable in the example system.
-/
theorem example_all_derivable : ∀ q : Fin 3, Derivable exampleSystem q := by
  intro q
  fin_cases q <;> simp_all +decide [ Derivable ];
  · exact ⟨ 0, example_deriv_0 ⟩;
  · exact ⟨ _, example_deriv_1 ⟩;
  · exact ⟨ _, example_deriv_2 ⟩

end TropicalProofValuationDuality