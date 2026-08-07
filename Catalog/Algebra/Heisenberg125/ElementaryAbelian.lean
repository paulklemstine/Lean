/-
# Olson's theorem for elementary abelian `p`-groups: `d((Z/p)^k) = k(p-1)`

The conjecture of Godara and Sarkar, `d(H_{p^3}) = 3p - 3`, says that the
non-abelian exponent-`p` group of order `p^3` has the *same* small Davenport
constant as the elementary abelian group `(Z/p)^3` of the same order.  This file
proves the abelian half of that statement in full generality:

  `d((Z/p)^k) = k(p - 1)`  for every prime `p` and every `k`.

* the upper bound is the multi-dimensional Chevalley–Warning bound
  `Heisenberg125.exists_nonempty_zeroSum_sublist_family` of
  `Algebra.Heisenberg125.ZeroSumTwoDim` (`D((Z/p)^k) ≤ k(p-1) + 1`);
* the lower bound is the explicit zero-sum-free sequence
  `e_0^{p-1} e_1^{p-1} ⋯ e_{k-1}^{p-1}`, whose zero-sum-freeness is proved by a
  counting argument: the `j`-th coordinate of the sum of a subsequence is the
  multiplicity of `e_j` in it, and multiplicities are bounded by `p - 1`.

For `k = 3` this gives `d((Z/p)^3) = 3p - 3`, and in particular
`d((Z/5)^3) = 12`, exactly the lower bound proved for `H_125`.
-/
import Algebra.Heisenberg125.AbelianDavenport

namespace Heisenberg125

open Multiplicative

variable {p k : ℕ}

/-! ### Two elementary list lemmas -/

/-- The sum of a list of functions is computed coordinatewise. -/
lemma pi_list_sum {ι : Type*} {A : ι → Type*} [∀ i, AddCommMonoid (A i)]
    (L : List (∀ i, A i)) (j : ι) : L.sum j = (L.map (fun f => f j)).sum := by
  induction L with
  | nil => rfl
  | cons g L ih => simp [ih]

/-- Summing the indicator function of `a` over a list counts the occurrences
of `a`. -/
lemma sum_map_indicator {α R : Type*} [DecidableEq α] [AddCommMonoidWithOne R]
    (T : List α) (a : α) :
    (T.map (fun g => if g = a then (1 : R) else 0)).sum = (T.count a : R) := by
  induction T with
  | nil => simp
  | cons g T ih =>
      rw [List.map_cons, List.sum_cons, ih, List.count_cons]
      by_cases h : g = a <;> simp [h, add_comm]

/-! ### The standard basis sequence -/

/-- The `j`-th standard basis vector of `(ZMod p)^k`, viewed multiplicatively. -/
def piBasis (p k : ℕ) (j : Fin k) : Multiplicative (Fin k → ZMod p) :=
  ofAdd (Pi.single j 1)

/-- The candidate extremal sequence `e_0^{p-1} ⋯ e_{k-1}^{p-1}` over
`(ZMod p)^k`. -/
def piBasisSeq (p k : ℕ) : List (Multiplicative (Fin k → ZMod p)) :=
  (List.finRange k).flatMap fun j => List.replicate (p - 1) (piBasis p k j)

lemma piBasis_ne (hp : 1 < p) {i j : Fin k} (h : i ≠ j) :
    piBasis p k i ≠ piBasis p k j := by
  haveI : Fact (1 < p) := ⟨hp⟩
  intro hc
  have hfun := congrFun (congrArg toAdd hc) i
  simp only [piBasis, toAdd_ofAdd, Pi.single_eq_same, Pi.single_eq_of_ne h] at hfun
  exact one_ne_zero hfun

@[simp] lemma length_piBasisSeq : (piBasisSeq p k).length = k * (p - 1) := by
  rw [piBasisSeq, List.length_flatMap]
  simp

lemma count_piBasisSeq (hp : 1 < p) (j : Fin k) :
    (piBasisSeq p k).count (piBasis p k j) = p - 1 := by
  classical
  rw [piBasisSeq, List.count_flatMap]
  have hmap : ((List.finRange k).map
        (List.count (piBasis p k j) ∘ fun i => List.replicate (p - 1) (piBasis p k i)))
      = (List.finRange k).map (fun i => if i = j then p - 1 else 0) := by
    refine List.map_congr_left fun i _ => ?_
    simp only [Function.comp_apply, List.count_replicate]
    by_cases h : i = j
    · subst h; simp
    · simp [h, piBasis_ne hp h]
  rw [hmap, ← Fin.sum_univ_def]
  simp

/-- **The lower bound.**  `e_0^{p-1} ⋯ e_{k-1}^{p-1}` is product-one-free. -/
theorem productOneFree_piBasisSeq (hp : 1 < p) :
    ProductOneFree (piBasisSeq p k) := by
  classical
  intro T hT hne hone
  rw [isProductOne_iff_sum_eq_zero] at hone
  obtain ⟨g, hg⟩ := List.exists_mem_of_ne_nil T hne
  have hgS : g ∈ piBasisSeq p k := hT.mem hg
  obtain ⟨j, rfl⟩ : ∃ j, g = piBasis p k j := by
    rw [piBasisSeq, List.mem_flatMap] at hgS
    obtain ⟨j, -, hj⟩ := hgS
    exact ⟨j, List.eq_of_mem_replicate hj⟩
  -- every entry of `T` is a basis vector, so the `j`-th coordinate of the sum
  -- counts the occurrences of `e_j`
  have hpt : ∀ h ∈ T, (toAdd h) j = (if h = piBasis p k j then (1 : ZMod p) else 0) := by
    intro h hh
    have hhS : h ∈ piBasisSeq p k := hT.mem hh
    obtain ⟨i, rfl⟩ : ∃ i, h = piBasis p k i := by
      rw [piBasisSeq, List.mem_flatMap] at hhS
      obtain ⟨i, -, hi⟩ := hhS
      exact ⟨i, List.eq_of_mem_replicate hi⟩
    by_cases hij : i = j
    · subst hij; simp [piBasis]
    · rw [if_neg (piBasis_ne hp hij)]
      simp [piBasis, hij]
  have hcoord : ((T.count (piBasis p k j) : ℕ) : ZMod p) = 0 := by
    have h0 := congrFun hone j
    rw [pi_list_sum, List.map_map] at h0
    have hmapeq : (T.map ((fun f => f j) ∘ toAdd))
        = T.map (fun g => if g = piBasis p k j then (1 : ZMod p) else 0) :=
      List.map_congr_left hpt
    rw [hmapeq, sum_map_indicator] at h0
    simpa using h0
  have hle : T.count (piBasis p k j) ≤ p - 1 := by
    have h1 := List.Sublist.count_le (piBasis p k j) hT
    rwa [count_piBasisSeq hp j] at h1
  have hzero := Heis.eq_zero_of_cast_eq_zero (by omega : 0 < p) hle hcoord
  have hpos : 0 < T.count (piBasis p k j) := List.count_pos_iff.2 hg
  omega

/-- **Olson's theorem for elementary abelian `p`-groups:**
`d((Z/p)^k) = k(p - 1)`. -/
theorem smallDavenport_pi (p k : ℕ) [Fact p.Prime] :
    smallDavenport (Multiplicative (Fin k → ZMod p)) = k * (p - 1) := by
  refine le_antisymm ?_ ?_
  · refine csSup_le ⟨0, ⟨[], rfl, productOneFree_nil⟩⟩ ?_
    rintro n ⟨L, rfl, hL⟩
    by_contra hlen
    push_neg at hlen
    obtain ⟨T, hTsub, hTne, hT⟩ :=
      exists_nonempty_zeroSum_sublist_family L (fun j g => (toAdd g) j) hlen
    refine hL T hTsub hTne ?_
    rw [isProductOne_iff_sum_eq_zero]
    funext j
    rw [pi_list_sum, List.map_map]
    simpa using hT j
  · have h := (productOneFree_piBasisSeq (p := p) (k := k)
      (Fact.out : p.Prime).one_lt).length_le_smallDavenport
    rwa [length_piBasisSeq] at h

/-- `d((Z/p)^3) = 3p - 3`: the value conjectured by Godara and Sarkar for the
non-abelian group `H_{p^3}` is exactly the small Davenport constant of the
elementary abelian group of the same order. -/
theorem smallDavenport_pi_three (p : ℕ) [Fact p.Prime] :
    smallDavenport (Multiplicative (Fin 3 → ZMod p)) = 3 * p - 3 := by
  have hp := (Fact.out : p.Prime).two_le
  rw [smallDavenport_pi p 3]
  omega

/-- The non-abelian group `H_{p^3}` is at least as rich as the elementary
abelian group of the same order: `d((Z/p)^3) ≤ d(H_{p^3})`.  Godara and Sarkar
conjecture that equality holds. -/
theorem smallDavenport_pi_three_le_heis (p : ℕ) [Fact p.Prime] :
    smallDavenport (Multiplicative (Fin 3 → ZMod p)) ≤ smallDavenport (Heis p) := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  have hp := (Fact.out : p.Prime).two_le
  have hlow := three_p_sub_three_le_smallDavenport (p := p)
  rw [smallDavenport_pi_three p]
  omega

/-- `d((Z/5)^3) = 12`, the same value as the lower bound proved for `H_125`. -/
theorem smallDavenport_pi_three_five :
    smallDavenport (Multiplicative (Fin 3 → ZMod 5)) = 12 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  rw [smallDavenport_pi_three 5]

end Heisenberg125