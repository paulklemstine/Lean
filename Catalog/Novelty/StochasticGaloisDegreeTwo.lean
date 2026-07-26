/-
# Exact Factorization Statistics of Random Monic Quadratics over a Finite Field

Let `K` be a finite field of odd characteristic, `q = |K|`.  A monic quadratic
`X^2 + bX + c` is encoded by `(b, c) : K × K`, so there are exactly `q^2` of them.
Its number of roots in `K` is `nroots b c := |{r : r^2 + b r + c = 0}|`.

We compute, *exactly*, the three refined counts:

* `card_double_root` : `q` quadratics have a repeated root (discriminant `= 0`);
* `card_reducible`   : `2 · #{reducible} = q(q+1)` (i.e. `q(q+1)/2` split into linear factors);
* `card_irreducible` : `2 · #{irreducible} = q(q-1)` (i.e. `q(q-1)/2` are irreducible).

Interpretation (the random-permutation dictionary for `S_2`):
* proportion with a repeated root `= 1/q → 0`  — this is the `n = 2` case of the prompt's
  `P(discriminant = 0) = 1/p`;
* proportion irreducible `= (q-1)/(2q) → 1/2`, matching the fraction of `2`-cycles in `S_2`;
* proportion reducible `= (q+1)/(2q) → 1/2`, matching the fraction of the identity in `S_2`.

Everything is derived from two structural facts: the total number of (quadratic, root)
incidences is `q^2` (`sum_nroots`), and a quadratic has at most two roots
(`nroots_le_two`).
-/
import Mathlib

open Finset BigOperators

namespace StochasticGalois

variable {K : Type*} [Field K] [Fintype K] [DecidableEq K]

/-- Number of roots in `K` of the monic quadratic `X^2 + bX + c`. -/
def nroots (b c : K) : ℕ := (Finset.univ.filter (fun r : K => r ^ 2 + b * r + c = 0)).card

/-
Completing the square: over a field of characteristic `≠ 2`, `r` is a root of
`X^2 + bX + c` iff `2r + b` is a square root of the discriminant `b^2 - 4c`.  Hence the
number of roots equals the number of square roots of the discriminant.
-/
lemma nroots_eq_disc (hchar : ringChar K ≠ 2) (b c : K) :
    nroots b c = (Finset.univ.filter (fun y : K => y ^ 2 = b ^ 2 - 4 * c)).card := by
  have h2 : (2 : K) ≠ 0 := Ring.two_ne_zero hchar
  refine Finset.card_bij (fun x _ => 2 * x + b) ?_ ?_ ?_
  · intro a ha
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha ⊢
    linear_combination (4 : K) * ha
  · intro a₁ _ a₂ _ h
    exact mul_left_cancel₀ h2 (add_right_cancel h)
  · intro y hy
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hy
    refine ⟨(y - b) / 2, ?_, by field_simp; ring⟩
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    field_simp
    linear_combination hy

/-
In a field of characteristic `≠ 2`, `a` has at most two square roots.
-/
lemma card_sqrts_le_two (a : K) :
    (Finset.univ.filter (fun y : K => y ^ 2 = a)).card ≤ 2 := by
  by_cases ha : ∃ y : K, y^2 = a;
  · obtain ⟨ y, rfl ⟩ := ha;
    refine' le_trans ( Finset.card_le_card _ ) _;
    exacts [ { y, -y }, fun x hx => by simpa [ sq_eq_sq_iff_eq_or_eq_neg ] using hx, Finset.card_insert_le _ _ ];
  · aesop

/-
In a field of characteristic `≠ 2`, `a` has exactly one square root iff `a = 0`.
-/
lemma card_sqrts_eq_one_iff (hchar : ringChar K ≠ 2) (a : K) :
    (Finset.univ.filter (fun y : K => y ^ 2 = a)).card = 1 ↔ a = 0 := by
  constructor <;> intro h
  · obtain ⟨y, hy⟩ := Finset.card_eq_one.mp h
    have hmem : y ∈ Finset.univ.filter (fun z : K => z ^ 2 = a) := by
      rw [hy]; exact Finset.mem_singleton_self y
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hmem
    have hmem2 : (-y) ∈ Finset.univ.filter (fun z : K => z ^ 2 = a) := by
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, neg_sq]; exact hmem
    rw [hy, Finset.mem_singleton] at hmem2
    have h2 : (2 : K) ≠ 0 := Ring.two_ne_zero hchar
    have hy0 : y = 0 := by
      have : (2 : K) * y = 0 := by linear_combination -hmem2
      exact (mul_eq_zero.mp this).resolve_left h2
    rw [← hmem, hy0]; ring
  · rw [Finset.card_eq_one]; exact ⟨0, by ext y; simp [pow_eq_zero_iff, h]⟩

/-- A monic quadratic has at most two roots. -/
lemma nroots_le_two (hchar : ringChar K ≠ 2) (b c : K) : nroots b c ≤ 2 := by
  rw [nroots_eq_disc hchar]; exact card_sqrts_le_two _

/-
**Total incidences.** Summed over all `q^2` monic quadratics, the total number of
(quadratic, root) incidences is `q^2`: for each base point `r`, exactly `q` quadratics
vanish at `r` (the constant term is forced).
-/
lemma sum_nroots : ∑ bc : K × K, nroots bc.1 bc.2 = (Fintype.card K) ^ 2 := by
  -- For each base point `r`, exactly `q` quadratics vanish at `r` (constant term forced).
  have fiber : ∀ r : K,
      (Finset.univ.filter (fun bc : K × K => r ^ 2 + bc.1 * r + bc.2 = 0)).card = Fintype.card K := by
    intro r
    rw [← Finset.card_univ (α := K)]
    refine Finset.card_bij' (fun bc _ => bc.1) (fun b _ => (b, -(r ^ 2 + b * r))) ?_ ?_ ?_ ?_
    · intro bc _; exact Finset.mem_univ _
    · intro b _
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]; ring
    · intro bc hbc
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hbc
      ext
      · rfl
      · simp only; linear_combination -hbc
    · intro b _; rfl
  simp_rw [nroots, Finset.card_filter]
  rw [Finset.sum_comm]
  simp_rw [← Finset.card_filter]
  rw [Finset.sum_congr rfl (fun r _ => fiber r)]
  rw [Finset.sum_const, Finset.card_univ, smul_eq_mul, sq]

/-
**Repeated-root count.** Exactly `q` monic quadratics have a repeated root, namely the
perfect squares `(X - r)^2`; equivalently the discriminant vanishes.
-/
lemma card_double_root (hchar : ringChar K ≠ 2) :
    (Finset.univ.filter (fun bc : K × K => nroots bc.1 bc.2 = 1)).card = Fintype.card K := by
  -- By completeness of root-characterization, rewrite the set using equivalent predicate
  have set_eq : Finset.filter (fun bc : K × K => nroots bc.1 bc.2 = 1) Finset.univ = Finset.filter (fun bc : K × K => bc.1 ^ 2 - 4 * bc.2 = 0) Finset.univ := by
    -- By nroots_eq_disc hchar, nroots b c = 1 iff b^2 - 4c = 0. So the filter {bc | nroots bc.1 bc.2 = 1} equals {bc | bc.1 ^ 2 - 4 * bc.2 = 0}.
    ext bc
    simp [nroots_eq_disc hchar, card_sqrts_eq_one_iff hchar];
  rw [ set_eq, Finset.card_eq_of_bijective ];
  use fun i hi => let x := Fintype.equivFin K |>.symm ⟨ i, hi ⟩; ( x, x^2 / 4 );
  · simp +decide [ sub_eq_zero ];
    intro a b hab; use ( Fintype.equivFin K ) a; simp +decide [ hab ] ;
    rw [ mul_div_cancel_left₀ _ ( show ( 4 : K ) ≠ 0 from by erw [ show ( 4 : K ) = 2 * 2 by norm_num ] ; exact mul_ne_zero ( by exact Ring.two_ne_zero hchar ) ( by exact Ring.two_ne_zero hchar ) ) ];
  · intro i hi; norm_num [ mul_div_cancel₀ ] ;
    rw [ mul_div_cancel₀ ] <;> norm_num;
    erw [ show ( 4 : K ) = 2 * 2 by norm_num, mul_eq_zero ] ; simp +decide [ hchar, Ring.two_ne_zero ];
  · aesop

/-
**Reducible count.** `2 · #{monic quadratics with a root} = q(q+1)`; equivalently
`q(q+1)/2` of the `q^2` monic quadratics split into linear factors.
-/
theorem card_reducible (hchar : ringChar K ≠ 2) :
    2 * (Finset.univ.filter (fun bc : K × K => ∃ r : K, r ^ 2 + bc.1 * r + bc.2 = 0)).card
      = Fintype.card K * (Fintype.card K + 1) := by
  -- Let's denote the number of monic quadratics with no roots, one root, and two roots as `n0`, `n1`, and `n2` respectively.
  set n0 := (Finset.univ.filter (fun bc : K × K => nroots bc.1 bc.2 = 0)).card
  set n1 := (Finset.univ.filter (fun bc : K × K => nroots bc.1 bc.2 = 1)).card
  set n2 := (Finset.univ.filter (fun bc : K × K => nroots bc.1 bc.2 = 2)).card;
  -- By definition of $n0$, $n1$, and $n2$, we have $n0 + n1 + n2 = q^2$ and $n1 + 2*n2 = q^2$.
  have h_partition : n0 + n1 + n2 = (Fintype.card K) ^ 2 := by
    rw [ ← Finset.card_union_of_disjoint, ← Finset.card_union_of_disjoint ];
    · convert Finset.card_univ ( α := K × K ) using 2;
      · ext bc; have := nroots_le_two hchar bc.1 bc.2; interval_cases _ : nroots bc.1 bc.2 <;> simp +decide [ * ] ;
      · simp +decide [ sq ];
    · exact Finset.disjoint_left.mpr ( by aesop );
    · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith
  have h_incidence : n1 + 2 * n2 = (Fintype.card K) ^ 2 := by
    have h_incidence : ∑ bc : K × K, nroots bc.1 bc.2 = n1 + 2 * n2 := by
      have h_incidence : ∀ bc : K × K, nroots bc.1 bc.2 = if nroots bc.1 bc.2 = 1 then 1 else if nroots bc.1 bc.2 = 2 then 2 else 0 := by
        intro bc; have := nroots_le_two hchar bc.1 bc.2; interval_cases nroots bc.1 bc.2 <;> trivial;
      rw [ Finset.sum_congr rfl fun x hx => h_incidence x ];
      simp +zetaDelta at *;
      simp +decide [ Finset.sum_ite, mul_comm ];
      exact congr_arg Finset.card ( Finset.ext fun x => by simp +contextual );
    rw [ ← h_incidence, sum_nroots ];
  -- By definition of $n1$ and $n2$, we have $n1 = q$.
  have h_double_root : n1 = Fintype.card K := by
    convert card_double_root hchar using 1;
  -- By definition of $n1$ and $n2$, we have $n1 + n2 = \text{cardinality of the set of reducible quadratics}$.
  have h_reducible : n1 + n2 = (Finset.univ.filter (fun bc : K × K => ∃ r : K, r ^ 2 + bc.1 * r + bc.2 = 0)).card := by
    rw [ ← Finset.card_union_of_disjoint ];
    · congr with bc ; simp +decide [ nroots ];
      constructor <;> intro h;
      · exact Exists.elim ( Finset.card_pos.mp ( by cases h <;> linarith ) ) fun x hx => ⟨ x, by simpa using hx ⟩;
      · have h_card : (Finset.univ.filter (fun r : K => r ^ 2 + bc.1 * r + bc.2 = 0)).card ≤ 2 := by
          convert nroots_le_two hchar bc.1 bc.2 using 1;
        interval_cases _ : Finset.card _ <;> simp_all +decide;
    · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith;
  lia

/-
**Irreducible count.** `2 · #{monic quadratics with no root} = q(q-1)`; equivalently
`q(q-1)/2` of the `q^2` monic quadratics are irreducible (Galois group `S_2`).
-/
theorem card_irreducible (hchar : ringChar K ≠ 2) :
    2 * (Finset.univ.filter (fun bc : K × K => ¬ ∃ r : K, r ^ 2 + bc.1 * r + bc.2 = 0)).card
      = Fintype.card K * (Fintype.card K - 1) := by
  -- Let's denote the number of pairs $(b, c)$ such that $x^2 + bx + c$ has no roots in $K$ by $n$.
  set n := Finset.card (Finset.filter (fun bc : K × K => ¬∃ r : K, r ^ 2 + bc.1 * r + bc.2 = 0) (Finset.univ : Finset (K × K)));
  -- By definition of $n$, we know that $n = q^2 - (q(q+1)/2)$.
  have h_n : n = (Fintype.card K)^2 - (Fintype.card K * (Fintype.card K + 1)) / 2 := by
    have h_card_reducible : (Finset.univ.filter (fun bc : K × K => ∃ r : K, r ^ 2 + bc.1 * r + bc.2 = 0)).card = (Fintype.card K * (Fintype.card K + 1)) / 2 := by
      exact Eq.symm ( Nat.div_eq_of_eq_mul_left zero_lt_two ( by linarith [ card_reducible hchar ] ) );
    rw [ ← h_card_reducible, eq_comm, tsub_eq_of_eq_add_rev ];
    rw [ Finset.card_filter_add_card_filter_not, Finset.card_univ ] ; simp +decide [ sq ];
  rw [ h_n, Nat.mul_sub_left_distrib ];
  exact Nat.sub_eq_of_eq_add <| by nlinarith only [ Nat.sub_add_cancel ( show 1 ≤ Fintype.card K from Fintype.card_pos ), Nat.div_mul_cancel ( show 2 ∣ Fintype.card K * ( Fintype.card K + 1 ) from even_iff_two_dvd.mp <| by simp +arith +decide [ mul_add, parity_simps ] ) ] ;

/-- Restatement over `ZMod p` (odd prime): `q(p+1)/2` reducible, `p(p-1)/2` irreducible. -/
theorem card_irreducible_zmod (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    2 * (Finset.univ.filter
        (fun bc : ZMod p × ZMod p => ¬ ∃ r : ZMod p, r ^ 2 + bc.1 * r + bc.2 = 0)).card
      = p * (p - 1) := by
  have hchar : ringChar (ZMod p) ≠ 2 := by
    rw [ZMod.ringChar_zmod_n]; exact hp
  have h := card_irreducible (K := ZMod p) hchar
  rwa [ZMod.card p] at h

end StochasticGalois