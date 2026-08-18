/-
# Power-sum rigidity for multisets of naturals

This file develops the purely combinatorial engine behind the *trace distribution*
theorem for finite group actions (`Logic.TraceDistribution.Core`).

The key statement is `multiset_eq_of_powerSum_eq_of_support`: a multiset of natural
numbers is completely determined by its first `n` power sums `p_k = ∑_{a ∈ A} a^k`,
`k < n`, as soon as `n` is at least the number of *distinct* values occurring in the
two multisets being compared.  Two convenient specialisations follow:

* `multiset_eq_of_powerSum_eq` — the value-bound form: if every element is `< n`, the
  power sums `p_0, …, p_{n-1}` determine the multiset;
* the support form is strictly stronger and is what gives the group-theoretic bound
  `2·|G|` in `Core`, independent of the size of the set being acted on.

The proof is a *Lagrange-interpolation duality* argument, not a Newton-identity
argument, and therefore never needs the two multisets to have equal cardinality
(the `k = 0` power sum records the cardinality automatically):

* `vanishing_of_power_sums` — if a `ℚ`-valued "signed measure" `c` supported on a
  finite set of `≤ n` distinct nodes annihilates every monomial `x^k`, `k < n`, then
  it annihilates every polynomial of degree `< n`, in particular the Lagrange basis
  polynomials, hence `c = 0`.
* `powerSum_cast_of_subset` — the bookkeeping identity rewriting a multiset power sum
  as a multiplicity-weighted sum over any finite set containing the multiset.

## Lab notes (experimental data)

Numerical checks performed while fixing the statement (see `ComputationalEvidence.md`):

* `A = {1,4}`, `B = {2,3}`: `p_0` agrees (`2 = 2`), `p_1` agrees (`5 = 5`), `p_2` does
  not (`17 ≠ 13`).  Support size is `4`, and indeed `k ≤ 1` is not enough.
* `A = {0,1,2}`, `B = {0,0,3}`: `p_0 = 3 = p_0`, `p_1 = 3 = p_1`, `p_2 = 5 ≠ 9`.
* The threshold is *exactly* optimal: `Logic.TraceDistribution.Sharpness` constructs,
  for every `n`, multisets `A ≠ B` with all values `≤ n` whose power sums agree for
  every `k < n` (the alternating binomial / `n`-th finite difference measure).
-/
import Mathlib

open Finset Polynomial

namespace TraceDistribution

/-- **Interpolation duality.**  Let `v : ι → ℚ` be injective on a finite set `S` with
`#S ≤ n`, and let `c : ι → ℚ` be arbitrary.  If the "moments"
`∑ i ∈ S, c i * (v i)^k` vanish for every `k < n`, then `c` vanishes on `S`.

The proof pairs the moment hypothesis against the Lagrange basis polynomial at each
node: it has degree `#S - 1 < n`, so it is a `ℚ`-combination of monomials that are
already known to be annihilated, while it evaluates to the Kronecker delta at the
nodes. -/
theorem vanishing_of_power_sums {ι : Type*} [DecidableEq ι] {S : Finset ι} {v : ι → ℚ}
    (hv : Set.InjOn v (S : Set ι)) {c : ι → ℚ} {n : ℕ} (hcard : S.card ≤ n)
    (h : ∀ k < n, ∑ i ∈ S, c i * (v i) ^ k = 0) : ∀ i ∈ S, c i = 0 := by
  intro w hw
  set P : ℚ[X] := Lagrange.basis S v w with hP
  have hdeg : P.natDegree < n := by
    rw [hP, Lagrange.natDegree_basis hv hw]
    have : 1 ≤ S.card := Finset.card_pos.mpr ⟨w, hw⟩
    omega
  -- Pairing `c` against the Lagrange basis polynomial at `w` isolates `c w`.
  have key : ∑ i ∈ S, c i * P.eval (v i) = c w := by
    rw [Finset.sum_eq_single w]
    · rw [Lagrange.eval_basis_self hv hw, mul_one]
    · intro b hb hbw
      rw [Lagrange.eval_basis_of_ne (Ne.symm hbw) hb, mul_zero]
    · intro hnw; exact absurd hw hnw
  have step : ∀ i ∈ S, c i * P.eval (v i) = ∑ k ∈ range n, c i * (P.coeff k * (v i) ^ k) := by
    intro i _
    rw [Polynomial.eval_eq_sum_range' hdeg, Finset.mul_sum]
  -- ... but the same pairing is a finite combination of the vanishing moments.
  have expand : ∑ i ∈ S, c i * P.eval (v i)
      = ∑ k ∈ range n, P.coeff k * (∑ i ∈ S, c i * (v i) ^ k) := by
    rw [Finset.sum_congr rfl step, Finset.sum_comm]
    refine Finset.sum_congr rfl fun k _ => ?_
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [← key, expand]
  exact Finset.sum_eq_zero fun k hk => by rw [h k (Finset.mem_range.mp hk), mul_zero]

/-- Rewriting a multiset power sum as a multiplicity-weighted sum over any finite set
containing the multiset. -/
theorem powerSum_cast_of_subset (A : Multiset ℕ) (S : Finset ℕ) (hA : ∀ a ∈ A, a ∈ S) (k : ℕ) :
    (((Multiset.map (fun a => a ^ k) A).sum : ℕ) : ℚ)
      = ∑ m ∈ S, (A.count m : ℚ) * (m : ℚ) ^ k := by
  classical
  have h1 : ((Multiset.map (fun a => a ^ k) A).sum : ℕ) = ∑ m ∈ A.toFinset, A.count m * m ^ k :=
    Finset.sum_multiset_map_count A (fun a => a ^ k)
  have h2 : ∑ m ∈ A.toFinset, ((A.count m : ℚ) * (m : ℚ) ^ k)
      = ∑ m ∈ S, ((A.count m : ℚ) * (m : ℚ) ^ k) := by
    refine Finset.sum_subset (fun x hx => hA x (Multiset.mem_toFinset.mp hx)) (fun x _ hx => ?_)
    simp [Multiset.count_eq_zero_of_notMem (fun hh => hx (Multiset.mem_toFinset.mpr hh))]
  rw [h1, ← h2]
  push_cast
  ring

/-- **Support form of power-sum rigidity.**  If the joint support of `A` and `B` has at
most `n` distinct values and the power sums `p_k` agree for all `k < n`, then `A = B`.

Note that `k = 0` is included, which is exactly what forces `A` and `B` to have the
same cardinality; no equal-cardinality hypothesis is needed. -/
theorem multiset_eq_of_powerSum_eq_of_support {A B : Multiset ℕ} {n : ℕ}
    (hcard : (A + B).toFinset.card ≤ n)
    (h : ∀ k < n, (Multiset.map (fun a => a ^ k) A).sum
      = (Multiset.map (fun a => a ^ k) B).sum) : A = B := by
  classical
  set S := (A + B).toFinset with hS
  have hAS : ∀ a ∈ A, a ∈ S := fun a ha =>
    Multiset.mem_toFinset.mpr (Multiset.mem_add.mpr (Or.inl ha))
  have hBS : ∀ b ∈ B, b ∈ S := fun b hb =>
    Multiset.mem_toFinset.mpr (Multiset.mem_add.mpr (Or.inr hb))
  have hvan : ∀ m ∈ S, ((A.count m : ℚ) - (B.count m : ℚ)) = 0 := by
    refine vanishing_of_power_sums (v := fun m : ℕ => (m : ℚ)) (n := n)
      Nat.cast_injective.injOn hcard ?_
    intro k hk
    have hh : ∀ m ∈ S, ((A.count m : ℚ) - (B.count m : ℚ)) * (m : ℚ) ^ k
        = (A.count m : ℚ) * (m : ℚ) ^ k - (B.count m : ℚ) * (m : ℚ) ^ k := fun m _ => by ring
    rw [Finset.sum_congr rfl hh, Finset.sum_sub_distrib,
      ← powerSum_cast_of_subset A S hAS k, ← powerSum_cast_of_subset B S hBS k, h k hk, sub_self]
  ext m
  by_cases hm : m ∈ S
  · have h1 := hvan m hm
    have h2 : (A.count m : ℚ) = (B.count m : ℚ) := by linarith
    exact_mod_cast h2
  · rw [Multiset.count_eq_zero_of_notMem (fun hh => hm (hAS m hh)),
      Multiset.count_eq_zero_of_notMem (fun hh => hm (hBS m hh))]

/-- **Value-bound form of power-sum rigidity.**  If every element of `A` and of `B` is
`< n`, and the power sums agree for all `k < n`, then `A = B`. -/
theorem multiset_eq_of_powerSum_eq {A B : Multiset ℕ} {n : ℕ}
    (hA : ∀ a ∈ A, a < n) (hB : ∀ b ∈ B, b < n)
    (h : ∀ k < n, (Multiset.map (fun a => a ^ k) A).sum
      = (Multiset.map (fun a => a ^ k) B).sum) : A = B := by
  classical
  refine multiset_eq_of_powerSum_eq_of_support ?_ h
  calc (A + B).toFinset.card ≤ (Finset.range n).card := by
        refine Finset.card_le_card fun x hx => ?_
        rcases Multiset.mem_add.mp (Multiset.mem_toFinset.mp hx) with hx' | hx'
        · exact Finset.mem_range.mpr (hA x hx')
        · exact Finset.mem_range.mpr (hB x hx')
    _ = n := Finset.card_range n

end TraceDistribution