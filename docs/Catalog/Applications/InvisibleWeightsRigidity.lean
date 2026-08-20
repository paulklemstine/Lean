/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.InvisibleWeightsSupport

/-!
# Rigidity at the sharp support bound: divided differences and forced alternation

`Applications/InvisibleWeightsSupport.lean` proves that a nonzero vector invisible to the
power-sum window `k < K` occupies at least `K + 1` nodes.  This file analyses the *equality
case*.  A vector living on exactly `K + 1` nodes has no freedom left at all: it is the
divided-difference functional of its own node set, up to one scalar.

## Main results

* `minimal_support_divided_difference` — **the rigidity identity.**  If `#S = K + 1` and the
  moments `∑_{j ∈ S} e j · j^k` vanish for all `k < K`, then for every node `i ∈ S`

  `e i · ∏_{j ∈ S \ {i}} (i - j) = ∑_{j ∈ S} e j · j^K`.

  The right-hand side does not depend on `i`, so `e` is the divided-difference weight vector
  of `S` scaled by its own top moment.  The proof is division-free: it evaluates the monic
  node polynomial `∏_{j ∈ S \ {i}} (X - j)` of degree `K` against `e` in two ways.
* `minimal_support_top_moment_ne_zero`, `minimal_support_ne_zero` — the top moment is nonzero
  as soon as one entry is, and then *every* entry of `e` on `S` is nonzero: minimal support
  vectors have full support on their node set.
* `minimal_support_alternating`, `minimal_support_sign_alternates` — **forced alternation.**
  The sign of `e i` is `(-1)^{#{j ∈ S : i > j}}` times a fixed global sign.  Reading `S` in
  increasing order, the entries alternate in sign: a Descartes-type conclusion obtained for
  free from the rigidity identity, without Descartes' rule.
* `minimal_support_proportional` — two invisible vectors on the same minimal node set are
  proportional (stated multiplicatively, so no division and no nondegeneracy hypothesis).
* `invisible_minimal_support_rigidity`, `invisible_minimal_support_alternating` — the same
  statements phrased for `Invisible N K e` and `nodeSupport N e`.
* `binWeight_rigidity` — consistency check: the shifted binomial vectors, which realise the
  bound, satisfy the identity with top moment `K !`.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).  The support bound `#S ≥ K + 1` is proved by a rank argument, so
the equality case should be a one-dimensional kernel: a vector on `K + 1` nodes killed by
the `K` conditions `k < K` must span a line.  Bold form: the line is *canonical* — it is the
divided difference of the node set — and therefore the sign pattern of any minimal-support
invisible vector is forced to alternate, whatever the node set is.

EXPERIMENT (Experimenter).  Both halves proved below.  The rigidity identity is obtained by
pairing `e` with the monic node polynomial `P_i = ∏_{j ≠ i} (X - j)`: on the one hand only
the node `i` survives, on the other hand only the leading coefficient `1` of `P_i` survives,
because every lower coefficient meets a vanishing moment.  Numerical check at `S = {0,1,2,3}`,
`K = 3`, `e = (-1, 3, -3, 1)`: `e 0 · (0-1)(0-2)(0-3) = -1 · (-6) = 6` and the top moment is
`-0 + 3 - 24 + 27 = 6`.  At `S = {0,1,3,4}`, `K = 3`, `e = (-1, 2, -2, 1)`:
`e 0 · (0-1)(0-3)(0-4) = -1 · (-12) = 12`, and the top moment is `2 - 54 + 64 = 12`.

ANALYSIS (Analyst).  The equality case is *rigid but not unique*: every `(K+1)`-element node
set `S ⊆ {0, …, N}` supports a one-dimensional space of invisible vectors, so the number of
minimal-support invisible lines is exactly `C(N+1, K+1)`, of which only the `N + 1 - K`
consecutive ones are the `binWeight` translates.  The alternation corollary explains the
experimentally observed sign patterns of every minimal `ℓ¹` witness found by search.

CRITIQUE (Critic).  The identity is stated with the product `∏_{j ∈ S \ {i}} (i - j)` on the
left rather than as a division, so it carries no hidden nonvanishing hypothesis and remains
true for the zero vector (both sides `0`).  The alternation statement is guarded by
`c ≠ 0`, which by `minimal_support_top_moment_ne_zero` is exactly the nondegeneracy of `e`.
-/

open Finset Polynomial

namespace InvisibleWeights

/-! ### The rigidity identity -/

/-- **Rigidity at the sharp support bound.**  A vector supported on `K + 1` nodes whose
moments of order `< K` all vanish is the divided-difference functional of its node set: for
every node `i`, the product of `e i` with `∏_{j ≠ i} (i - j)` equals the top moment, which is
independent of `i`. -/
theorem minimal_support_divided_difference {K : ℕ} {S : Finset ℕ} {e : ℕ → ℚ}
    (hcard : S.card = K + 1) (hvan : ∀ k < K, ∑ j ∈ S, e j * (j : ℚ) ^ k = 0)
    {i : ℕ} (hi : i ∈ S) :
    e i * ∏ j ∈ S.erase i, ((i : ℚ) - (j : ℚ)) = ∑ j ∈ S, e j * (j : ℚ) ^ K := by
  classical
  set P : ℚ[X] := Lagrange.nodal (S.erase i) (fun j : ℕ => (j : ℚ)) with hP
  have hcarderase : (S.erase i).card = K := by
    rw [Finset.card_erase_of_mem hi, hcard]
    rfl
  have hmonic : P.Monic := Lagrange.nodal_monic
  have hdeg : P.natDegree = K := by rw [hP, Lagrange.natDegree_nodal, hcarderase]
  have hcoeffK : P.coeff K = 1 := by
    have := hmonic.coeff_natDegree
    rwa [hdeg] at this
  have heval : ∀ x : ℚ, P.eval x = ∏ j ∈ S.erase i, (x - (j : ℚ)) := fun x => Lagrange.eval_nodal
  have h1 : ∑ j ∈ S, e j * P.eval (j : ℚ) = e i * ∏ j ∈ S.erase i, ((i : ℚ) - (j : ℚ)) := by
    rw [← Finset.sum_erase_add _ _ hi, heval]
    have hzero : ∀ j ∈ S.erase i, e j * P.eval (j : ℚ) = 0 := by
      intro j hj
      rw [heval]
      rw [Finset.prod_eq_zero hj (by ring), mul_zero]
    rw [Finset.sum_congr rfl hzero, Finset.sum_const_zero, zero_add]
  have h2 : ∑ j ∈ S, e j * P.eval (j : ℚ) = ∑ j ∈ S, e j * (j : ℚ) ^ K := by
    have hexp : ∀ j : ℕ, P.eval (j : ℚ) = ∑ k ∈ range (K + 1), P.coeff k * (j : ℚ) ^ k :=
      fun j => Polynomial.eval_eq_sum_range' (by omega : P.natDegree < K + 1) _
    calc ∑ j ∈ S, e j * P.eval (j : ℚ)
        = ∑ j ∈ S, ∑ k ∈ range (K + 1), P.coeff k * (e j * (j : ℚ) ^ k) := by
          refine Finset.sum_congr rfl fun j _ => ?_
          rw [hexp j, Finset.mul_sum]
          exact Finset.sum_congr rfl fun k _ => by ring
      _ = ∑ k ∈ range (K + 1), P.coeff k * ∑ j ∈ S, e j * (j : ℚ) ^ k := by
          rw [Finset.sum_comm]
          exact Finset.sum_congr rfl fun k _ => by rw [Finset.mul_sum]
      _ = ∑ j ∈ S, e j * (j : ℚ) ^ K := by
          rw [Finset.sum_range_succ]
          have hlow : ∀ k ∈ range K, P.coeff k * ∑ j ∈ S, e j * (j : ℚ) ^ k = 0 := by
            intro k hk
            rw [hvan k (mem_range.mp hk), mul_zero]
          rw [Finset.sum_congr rfl hlow, Finset.sum_const_zero, zero_add, hcoeffK, one_mul]
  rw [← h1, h2]

/-- The node product `∏_{j ∈ S \ {i}} (i - j)` never vanishes: the nodes are distinct. -/
lemma prod_erase_ne_zero (S : Finset ℕ) (i : ℕ) :
    ∏ j ∈ S.erase i, ((i : ℚ) - (j : ℚ)) ≠ 0 := by
  refine Finset.prod_ne_zero_iff.mpr fun j hj => ?_
  have hne : j ≠ i := (Finset.mem_erase.mp hj).1
  have : (j : ℚ) ≠ (i : ℚ) := by exact_mod_cast hne
  intro hc
  exact this (by linarith [sub_eq_zero.mp hc])

/-- At the sharp support bound the top moment detects nondegeneracy: it is nonzero as soon as
a single entry of `e` on `S` is nonzero. -/
theorem minimal_support_top_moment_ne_zero {K : ℕ} {S : Finset ℕ} {e : ℕ → ℚ}
    (hcard : S.card = K + 1) (hvan : ∀ k < K, ∑ j ∈ S, e j * (j : ℚ) ^ k = 0)
    {i : ℕ} (hi : i ∈ S) (hne : e i ≠ 0) :
    ∑ j ∈ S, e j * (j : ℚ) ^ K ≠ 0 := by
  rw [← minimal_support_divided_difference hcard hvan hi]
  exact mul_ne_zero hne (prod_erase_ne_zero S i)

/-- **Full support.**  A nondegenerate minimal-support invisible vector has *all* `K + 1`
entries nonzero: no node of `S` can carry weight `0`. -/
theorem minimal_support_ne_zero {K : ℕ} {S : Finset ℕ} {e : ℕ → ℚ}
    (hcard : S.card = K + 1) (hvan : ∀ k < K, ∑ j ∈ S, e j * (j : ℚ) ^ k = 0)
    (hc : ∑ j ∈ S, e j * (j : ℚ) ^ K ≠ 0) {i : ℕ} (hi : i ∈ S) :
    e i ≠ 0 := by
  intro h0
  apply hc
  rw [← minimal_support_divided_difference hcard hvan hi, h0, zero_mul]

/-! ### Forced alternation of signs -/

/-- The sign of the node product `∏_{j ∈ S \ {i}} (i - j)` is `(-1)^{#\{j ∈ S : i < j\}}`:
exactly the nodes above `i` contribute a negative factor. -/
lemma sign_prod_erase (S : Finset ℕ) (i : ℕ) :
    0 < (-1 : ℚ) ^ ((S.filter fun j => i < j).card) *
      ∏ j ∈ S.erase i, ((i : ℚ) - (j : ℚ)) := by
  classical
  have hsplit := Finset.prod_filter_mul_prod_filter_not (S.erase i) (fun j => j < i)
    (fun j => ((i : ℚ) - (j : ℚ)))
  have hB : ((S.erase i).filter fun j => ¬ j < i) = S.filter (fun j => i < j) := by
    ext j
    simp only [Finset.mem_filter, Finset.mem_erase, not_lt]
    constructor
    · rintro ⟨⟨hne, hjS⟩, hle⟩
      exact ⟨hjS, lt_of_le_of_ne hle (Ne.symm hne)⟩
    · rintro ⟨hjS, hlt⟩
      exact ⟨⟨by omega, hjS⟩, by omega⟩
  set m := (S.filter fun j => i < j).card with hm
  set A := ∏ j ∈ (S.erase i).filter (fun j => j < i), ((i : ℚ) - (j : ℚ)) with hA
  set B := ∏ j ∈ S.filter (fun j => i < j), ((j : ℚ) - (i : ℚ)) with hBdef
  have hApos : 0 < A := by
    refine Finset.prod_pos fun j hj => ?_
    have hji : j < i := (Finset.mem_filter.mp hj).2
    have : (j : ℚ) < (i : ℚ) := by exact_mod_cast hji
    linarith
  have hBpos : 0 < B := by
    refine Finset.prod_pos fun j hj => ?_
    have hij : i < j := (Finset.mem_filter.mp hj).2
    have : (i : ℚ) < (j : ℚ) := by exact_mod_cast hij
    linarith
  have hBeq : ∏ j ∈ (S.erase i).filter (fun j => ¬ j < i), ((i : ℚ) - (j : ℚ))
      = (-1 : ℚ) ^ m * B := by
    rw [hB, hBdef, ← Finset.prod_const, ← Finset.prod_mul_distrib]
    exact Finset.prod_congr rfl fun j _ => by ring
  have hsq : (-1 : ℚ) ^ m * ((-1 : ℚ) ^ m) = 1 := by
    rw [← pow_add, ← two_mul, pow_mul]
    norm_num
  rw [← hsplit, hBeq]
  have key : (-1 : ℚ) ^ m * (A * ((-1 : ℚ) ^ m * B))
      = ((-1 : ℚ) ^ m * (-1 : ℚ) ^ m) * (A * B) := by ring
  rw [key, hsq, one_mul]
  exact mul_pos hApos hBpos

/-- **Forced alternation.**  For a nondegenerate minimal-support invisible vector, the sign of
`(-1)^{#\{j ∈ S : i < j\}} · e i` is the sign of the top moment — the same for every node. -/
theorem minimal_support_alternating {K : ℕ} {S : Finset ℕ} {e : ℕ → ℚ}
    (hcard : S.card = K + 1) (hvan : ∀ k < K, ∑ j ∈ S, e j * (j : ℚ) ^ k = 0)
    (hc : ∑ j ∈ S, e j * (j : ℚ) ^ K ≠ 0) {i : ℕ} (hi : i ∈ S) :
    0 < ((-1 : ℚ) ^ ((S.filter fun j => i < j).card) * e i) *
      ∑ j ∈ S, e j * (j : ℚ) ^ K := by
  classical
  set m := (S.filter fun j => i < j).card with hm
  set p := ∏ j ∈ S.erase i, ((i : ℚ) - (j : ℚ)) with hp
  have hid := minimal_support_divided_difference hcard hvan hi
  have hei : e i ≠ 0 := minimal_support_ne_zero hcard hvan hc hi
  have hsign : 0 < (-1 : ℚ) ^ m * p := sign_prod_erase S i
  have hrw : ((-1 : ℚ) ^ m * e i) * (∑ j ∈ S, e j * (j : ℚ) ^ K)
      = (e i * e i) * ((-1 : ℚ) ^ m * p) := by
    rw [← hid]
    ring
  rw [hrw]
  exact mul_pos (mul_self_pos.mpr hei) hsign

/-- Two nodes of a nondegenerate minimal-support invisible vector carry weights whose signs
differ exactly by the parity of the number of nodes between them. -/
theorem minimal_support_sign_alternates {K : ℕ} {S : Finset ℕ} {e : ℕ → ℚ}
    (hcard : S.card = K + 1) (hvan : ∀ k < K, ∑ j ∈ S, e j * (j : ℚ) ^ k = 0)
    (hc : ∑ j ∈ S, e j * (j : ℚ) ^ K ≠ 0) {i i' : ℕ} (hi : i ∈ S) (hi' : i' ∈ S) :
    0 < ((-1 : ℚ) ^ ((S.filter fun j => i < j).card) * e i) *
      ((-1 : ℚ) ^ ((S.filter fun j => i' < j).card) * e i') := by
  have h1 := minimal_support_alternating hcard hvan hc hi
  have h2 := minimal_support_alternating hcard hvan hc hi'
  set c := ∑ j ∈ S, e j * (j : ℚ) ^ K with hcdef
  nlinarith [sq_nonneg c, mul_pos h1 h2]

/-- **Proportionality.**  Two invisible vectors on the same minimal node set are proportional;
stated multiplicatively so that no nondegeneracy hypothesis is needed. -/
theorem minimal_support_proportional {K : ℕ} {S : Finset ℕ} {e f : ℕ → ℚ}
    (hcard : S.card = K + 1)
    (hvane : ∀ k < K, ∑ j ∈ S, e j * (j : ℚ) ^ k = 0)
    (hvanf : ∀ k < K, ∑ j ∈ S, f j * (j : ℚ) ^ k = 0)
    {i : ℕ} (hi : i ∈ S) :
    e i * (∑ j ∈ S, f j * (j : ℚ) ^ K) = f i * (∑ j ∈ S, e j * (j : ℚ) ^ K) := by
  rw [← minimal_support_divided_difference hcard hvane hi,
    ← minimal_support_divided_difference hcard hvanf hi]
  ring

/-! ### The same statements for `Invisible` and `nodeSupport` -/

/-- Rigidity for an invisible vector attaining the sharp support bound. -/
theorem invisible_minimal_support_rigidity {N K : ℕ} {e : ℕ → ℚ} (he : Invisible N K e)
    (hcard : (nodeSupport N e).card = K + 1) {i : ℕ} (hi : i ∈ nodeSupport N e) :
    e i * ∏ j ∈ (nodeSupport N e).erase i, ((i : ℚ) - (j : ℚ)) = moment N e K := by
  have hvan : ∀ k < K, ∑ j ∈ nodeSupport N e, e j * (j : ℚ) ^ k = 0 := by
    intro k hk
    rw [← moment_eq_sum_nodeSupport]
    exact he k hk
  rw [minimal_support_divided_difference hcard hvan hi, moment_eq_sum_nodeSupport]

/-- A nonzero invisible vector attaining the sharp support bound has nonzero top moment: the
window `k < K` misses it, but the very next moment sees it. -/
theorem invisible_minimal_support_moment_ne_zero {N K : ℕ} {e : ℕ → ℚ} (he : Invisible N K e)
    (hcard : (nodeSupport N e).card = K + 1) {i : ℕ} (hi : i ∈ nodeSupport N e) :
    moment N e K ≠ 0 := by
  have hvan : ∀ k < K, ∑ j ∈ nodeSupport N e, e j * (j : ℚ) ^ k = 0 := by
    intro k hk
    rw [← moment_eq_sum_nodeSupport]
    exact he k hk
  rw [moment_eq_sum_nodeSupport]
  exact minimal_support_top_moment_ne_zero hcard hvan hi (mem_nodeSupport.mp hi).2

/-- Alternation for an invisible vector attaining the sharp support bound. -/
theorem invisible_minimal_support_alternating {N K : ℕ} {e : ℕ → ℚ} (he : Invisible N K e)
    (hcard : (nodeSupport N e).card = K + 1) {i i' : ℕ}
    (hi : i ∈ nodeSupport N e) (hi' : i' ∈ nodeSupport N e) :
    0 < ((-1 : ℚ) ^ (((nodeSupport N e).filter fun j => i < j).card) * e i) *
      ((-1 : ℚ) ^ (((nodeSupport N e).filter fun j => i' < j).card) * e i') := by
  have hvan : ∀ k < K, ∑ j ∈ nodeSupport N e, e j * (j : ℚ) ^ k = 0 := by
    intro k hk
    rw [← moment_eq_sum_nodeSupport]
    exact he k hk
  have hc : ∑ j ∈ nodeSupport N e, e j * (j : ℚ) ^ K ≠ 0 :=
    minimal_support_top_moment_ne_zero hcard hvan hi (mem_nodeSupport.mp hi).2
  exact minimal_support_sign_alternates hcard hvan hc hi hi'

/-! ### Consistency check on the binomial vectors -/

/-- The shifted binomial vector realises the rigidity identity on its own node set, with top
moment `K !`. -/
theorem binWeight_rigidity {N K i₀ : ℕ} (hN : i₀ + K ≤ N) {i : ℕ}
    (hi : i ∈ nodeSupport N (binWeight (R := ℚ) K i₀)) :
    binWeight (R := ℚ) K i₀ i *
        ∏ j ∈ (nodeSupport N (binWeight (R := ℚ) K i₀)).erase i, ((i : ℚ) - (j : ℚ))
      = (K.factorial : ℚ) := by
  have hcard : (nodeSupport N (binWeight (R := ℚ) K i₀)).card = K + 1 :=
    card_nodeSupport_binWeight hN
  rw [invisible_minimal_support_rigidity (binWeight_invisible hN) hcard hi,
    moment_binWeight_top hN]

end InvisibleWeights