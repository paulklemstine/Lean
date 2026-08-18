/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.NearMissUniversality

/-!
# Near misses on arbitrary node sets

Cycle 5 of the near-miss research thread.  Everything proved so far concerned multisets whose
values lie in the *interval* `{0, 1, …, N}`.  The bold conjecture tested here is that the
interval plays no role: for **any** set `A` of `N + 1` distinct values, the near misses
supported in `A` again form a single one-parameter family, and the generator is the vector of
inverse *nodal weights* `a ↦ (∏_{b ∈ A, b ≠ a} (a - b))⁻¹`.

## Main results

* `vandermonde_kernel_weighted` — the linear-algebra core, over an arbitrary field.  If
  `v` indexes `N + 1` distinct nodes of a field `F` and the weights `e` satisfy
  `∑_i e i · v i ^ k = 0` for all `k < N`, then `e i · ∏_{j ≠ i} (v i - v j)` is the *same*
  element of `F` for every `i` (namely `∑_i e i · v i ^ N`).  Equivalently: the kernel of the
  truncated `N × (N+1)` Vandermonde matrix is the line spanned by the inverse nodal weights.
  The proof evaluates the functional `e` against the Lagrange basis polynomial at a node,
  a genuine algebra ↔ combinatorics bridge.
* `near_miss_general_nodes` — the Prouhet–Tarry–Escott style consequence: two multisets of
  naturals taking values in an arbitrary `A : Finset ℕ` with `#A = N + 1`, and agreeing on
  all power sums `k < N`, have multiplicity difference proportional to
  `a ↦ (∏_{b ∈ A.erase a} (a - b))⁻¹`, with one universal constant of proportionality.
* `support_union_general_nodes`, `card_support_general_nodes` — the support results of
  `Applications/NearMissSupport.lean` survive verbatim on an arbitrary node set: the two
  supports cover all `N + 1` nodes, so their sizes sum to at least `N + 1` and the larger
  side has at least `⌈(N+1)/2⌉` distinct values.  Since the interval binomial pair attains
  these, the answer `⌈(N+1)/2⌉` is optimal in this much wider class too.
* `near_miss_general_nodes_rigid` — hence, on a fixed node set, one nonzero multiplicity
  difference determines all of them; in particular if the difference vanishes at a single
  node then the two multisets are equal.

The interval case `A = {0,…,N}` recovers `near_miss_classification`, whose kernel vector
`j ↦ (-1)^j C(N,j)` is exactly the inverse nodal weight profile of the interval, rescaled
by `N !`.
-/

open Finset

namespace PowerSumSharpness

/-! ### The kernel of a truncated Vandermonde system -/

/-- **Kernel of the truncated Vandermonde system.**  For `N + 1` distinct nodes `v i` of a
field, any weight vector `e` killing all power sums of order `k < N` satisfies
`e i · ∏_{j ≠ i} (v i - v j) = ∑_i e i · v i ^ N`, a quantity independent of `i`.  So the
kernel is at most one-dimensional and is spanned by the inverse nodal weights. -/
theorem vandermonde_kernel_weighted {F : Type*} [Field F] {ι : Type*} [DecidableEq ι]
    {s : Finset ι} {v : ι → F} (hvs : Set.InjOn v s) {N : ℕ} (hcard : s.card = N + 1)
    {e : ι → F} (h : ∀ k < N, ∑ i ∈ s, e i * v i ^ k = 0) {i₀ : ι} (hi₀ : i₀ ∈ s) :
    e i₀ * ∏ j ∈ s.erase i₀, (v i₀ - v j) = ∑ i ∈ s, e i * v i ^ N := by
  classical
  set p : Polynomial F := Lagrange.basis s v i₀ with hp
  have hdeg : p.natDegree = N := by
    rw [hp, Lagrange.natDegree_basis hvs hi₀, hcard]
    omega
  -- the functional `e` applied to the Lagrange basis polynomial picks out `e i₀`
  have hsel : ∑ i ∈ s, e i * p.eval (v i) = e i₀ := by
    rw [Finset.sum_eq_single i₀]
    · rw [hp, Lagrange.eval_basis_self hvs hi₀, mul_one]
    · intro b hb hbne
      rw [hp, Lagrange.eval_basis_of_ne (Ne.symm hbne) hb, mul_zero]
    · intro hcon; exact absurd hi₀ hcon
  -- expanding `p` in the monomial basis, only the top coefficient survives
  have hexp : ∑ i ∈ s, e i * p.eval (v i)
      = ∑ k ∈ Finset.range (N + 1), p.coeff k * ∑ i ∈ s, e i * v i ^ k := by
    have hpe : ∀ i, p.eval (v i) = ∑ k ∈ Finset.range (N + 1), p.coeff k * v i ^ k :=
      fun i => Polynomial.eval_eq_sum_range' (by omega) (v i)
    calc ∑ i ∈ s, e i * p.eval (v i)
        = ∑ i ∈ s, ∑ k ∈ Finset.range (N + 1), p.coeff k * (e i * v i ^ k) := by
          refine Finset.sum_congr rfl fun i _ => ?_
          rw [hpe i, Finset.mul_sum]
          exact Finset.sum_congr rfl fun k _ => by ring
      _ = ∑ k ∈ Finset.range (N + 1), ∑ i ∈ s, p.coeff k * (e i * v i ^ k) := Finset.sum_comm
      _ = ∑ k ∈ Finset.range (N + 1), p.coeff k * ∑ i ∈ s, e i * v i ^ k :=
          Finset.sum_congr rfl fun k _ => (Finset.mul_sum _ _ _).symm
  have htop : ∑ k ∈ Finset.range (N + 1), p.coeff k * ∑ i ∈ s, e i * v i ^ k
      = p.coeff N * ∑ i ∈ s, e i * v i ^ N := by
    refine Finset.sum_eq_single N ?_ ?_
    · intro k hk hkN
      rw [h k (by have := Finset.mem_range.mp hk; omega), mul_zero]
    · intro hcon
      exact absurd (Finset.self_mem_range_succ N) hcon
  -- the top coefficient is the inverse nodal weight
  have hW : ∏ j ∈ s.erase i₀, (v i₀ - v j) ≠ 0 := by
    refine Finset.prod_ne_zero_iff.mpr fun j hj => ?_
    obtain ⟨hij, hjs⟩ := Finset.mem_erase.mp hj
    exact sub_ne_zero_of_ne fun hc => hij ((hvs.eq_iff hjs hi₀).mp hc.symm)
  have hcoeff : p.coeff N = (∏ j ∈ s.erase i₀, (v i₀ - v j))⁻¹ := by
    rw [← hdeg, ← Polynomial.leadingCoeff, hp, Lagrange.leadingCoeff_basis hvs hi₀]
  rw [hexp, htop, hcoeff] at hsel
  field_simp at hsel
  linear_combination -hsel

/-! ### Power sums over an arbitrary finite value set -/

lemma powerSum_eq_sum_over_finset {A : Finset ℕ} {s : Multiset ℕ} (hs : ∀ x ∈ s, x ∈ A)
    (k : ℕ) : (powerSum s k : ℚ) = ∑ a ∈ A, (s.count a : ℚ) * (a : ℚ) ^ k := by
  classical
  set M : ℕ := A.sup id with hM
  have hbound : ∀ x ∈ s, x ≤ M := fun x hx => Finset.le_sup (f := id) (hs x hx)
  have hsub : A ⊆ Finset.range (M + 1) := fun a ha =>
    Finset.mem_range.mpr (Nat.lt_succ_of_le (Finset.le_sup (f := id) ha))
  rw [powerSum_eq_sum_counts hbound]
  refine (Finset.sum_subset hsub ?_).symm
  intro j _ hjA
  have : s.count j = 0 := Multiset.count_eq_zero.mpr fun hmem => hjA (hs j hmem)
  rw [this]
  simp

/-! ### The Prouhet–Tarry–Escott form: near misses on an arbitrary node set -/

/-- **Near misses on an arbitrary node set.**  If two multisets of naturals take their values
in a set `A` of exactly `N + 1` numbers and share all power sums of order `k < N`, then their
multiplicity difference is the inverse nodal weight profile of `A`, scaled by one universal
constant.  For `A = {0,…,N}` this is `near_miss_classification`; for a general `A` it is new,
and it says that the *shape* of a near miss depends only on the node set, never on the
multiset. -/
theorem near_miss_general_nodes {N : ℕ} {A : Finset ℕ} (hA : A.card = N + 1)
    {s t : Multiset ℕ} (hs : ∀ x ∈ s, x ∈ A) (ht : ∀ x ∈ t, x ∈ A)
    (h : ∀ k < N, powerSum s k = powerSum t k) :
    ∃ c : ℚ, ∀ a ∈ A,
      ((s.count a : ℚ) - (t.count a : ℚ)) * ∏ b ∈ A.erase a, ((a : ℚ) - (b : ℚ)) = c := by
  classical
  set e : ℕ → ℚ := fun a => (s.count a : ℚ) - (t.count a : ℚ) with he
  have hker : ∀ k < N, ∑ a ∈ A, e a * (a : ℚ) ^ k = 0 := by
    intro k hk
    have h1 := powerSum_eq_sum_over_finset hs k
    have h2 := powerSum_eq_sum_over_finset ht k
    have h3 : (powerSum s k : ℚ) = (powerSum t k : ℚ) := by rw [h k hk]
    rw [h1, h2] at h3
    rw [← sub_eq_zero] at h3
    rw [← h3, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun a _ => by rw [he]; ring
  refine ⟨∑ a ∈ A, e a * (a : ℚ) ^ N, fun a ha => ?_⟩
  exact vandermonde_kernel_weighted
    (v := fun n : ℕ => (n : ℚ))
    (fun x _ y _ hxy => Nat.cast_injective hxy) hA hker ha

/-- **Rigidity on a general node set.**  On a fixed set of `N + 1` nodes, if the two
multiplicities of a power-sum near miss agree at even a single node, the two multisets are
equal.  (The interval case is `count_diff_eq_smul_alternating`.) -/
theorem near_miss_general_nodes_rigid {N : ℕ} {A : Finset ℕ} (hA : A.card = N + 1)
    {s t : Multiset ℕ} (hs : ∀ x ∈ s, x ∈ A) (ht : ∀ x ∈ t, x ∈ A)
    (h : ∀ k < N, powerSum s k = powerSum t k) {a₀ : ℕ} (ha₀ : a₀ ∈ A)
    (hzero : s.count a₀ = t.count a₀) : s = t := by
  classical
  obtain ⟨c, hc⟩ := near_miss_general_nodes hA hs ht h
  have hc0 : c = 0 := by
    have := hc a₀ ha₀
    rw [hzero] at this
    simpa using this.symm
  refine Multiset.ext.mpr fun m => ?_
  by_cases hm : m ∈ A
  · have hW : ∏ b ∈ A.erase m, ((m : ℚ) - (b : ℚ)) ≠ 0 := by
      refine Finset.prod_ne_zero_iff.mpr fun b hb => ?_
      obtain ⟨hmb, _⟩ := Finset.mem_erase.mp hb
      exact sub_ne_zero_of_ne fun hcon => hmb (by exact_mod_cast hcon.symm)
    have := hc m hm
    rw [hc0] at this
    rcases mul_eq_zero.mp this with h1 | h1
    · have : (s.count m : ℚ) = (t.count m : ℚ) := by linarith
      exact_mod_cast this
    · exact absurd h1 hW
  · rw [Multiset.count_eq_zero.mpr fun hmem => hm (hs m hmem),
      Multiset.count_eq_zero.mpr fun hmem => hm (ht m hmem)]


/-! ### The support bound survives on an arbitrary node set -/

/-- **Every node is used.**  On any node set `A` of size `N + 1`, the two sides of a genuine
near miss have multiplicities differing at *every* node; consequently their supports cover
`A`.  This generalises `support_union_eq_range` from the interval `{0,…,N}` to arbitrary
nodes. -/
theorem support_union_general_nodes {N : ℕ} {A : Finset ℕ} (hA : A.card = N + 1)
    {s t : Multiset ℕ} (hs : ∀ x ∈ s, x ∈ A) (ht : ∀ x ∈ t, x ∈ A)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t) :
    support s ∪ support t = A := by
  classical
  refine Finset.Subset.antisymm (Finset.union_subset ?_ ?_) ?_
  · intro j hj
    rw [support, Multiset.mem_toFinset] at hj
    exact hs j hj
  · intro j hj
    rw [support, Multiset.mem_toFinset] at hj
    exact ht j hj
  · intro a ha
    by_contra hmem
    rw [Finset.mem_union] at hmem
    push_neg at hmem
    obtain ⟨h1, h2⟩ := hmem
    have hc1 : s.count a = 0 := by
      by_contra hc
      exact h1 (mem_support.mpr (Nat.pos_of_ne_zero hc))
    have hc2 : t.count a = 0 := by
      by_contra hc
      exact h2 (mem_support.mpr (Nat.pos_of_ne_zero hc))
    exact hne (near_miss_general_nodes_rigid hA hs ht h ha (by rw [hc1, hc2]))

/-- **Support lower bounds on an arbitrary node set.**  A near miss on `N + 1` arbitrary
nodes still needs `N + 1` distinct values in total, hence `⌈(N+1)/2⌉` on its larger side.
The binomial pair on the interval attains both, so the bounds of
`binomial_pair_minimises_support` are optimal even in this wider class. -/
theorem card_support_general_nodes {N : ℕ} {A : Finset ℕ} (hA : A.card = N + 1)
    {s t : Multiset ℕ} (hs : ∀ x ∈ s, x ∈ A) (ht : ∀ x ∈ t, x ∈ A)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t) :
    N + 1 ≤ (support s).card + (support t).card ∧
      (N + 2) / 2 ≤ max (support s).card (support t).card := by
  classical
  have hu := support_union_general_nodes hA hs ht h hne
  have hsum : N + 1 ≤ (support s).card + (support t).card := by
    calc N + 1 = A.card := hA.symm
      _ = (support s ∪ support t).card := by rw [hu]
      _ ≤ (support s).card + (support t).card := Finset.card_union_le _ _
  refine ⟨hsum, ?_⟩
  rcases le_total (support s).card (support t).card with hle | hle
  · rw [max_eq_right hle]; omega
  · rw [max_eq_left hle]; omega

end PowerSumSharpness