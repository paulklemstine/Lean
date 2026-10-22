import Mathlib
import Shared.QSFactorBaseDimension

/-!
# Round 42, item 4: which way does `rank ≤ Q` point?  The prefix-rank identity

The sieve produces relation (exponent) vectors `v₀, v₁, v₂, …` in `𝔽₂^Q`, where
`Q = Q(N,B)` is the number of admissible primes (`Catalog.Computation.QSSplitSetForcing`).
`k_success` is the length of the *shortest* prefix that is linearly dependent.
Round 42 asserted that the chain `k_success ≤ rank + 1 ≤ Q + 1` "has its first
inequality backwards".  This file settles the question exactly, over any field,
and finds that **both readings are right about different ranks**:

* `prefixRank_add_one_le_of_dependent` — for any dependent prefix of length `k`,
  `rank(prefix k) + 1 ≤ k` (round 42's correction, for the *prefix* rank);
* `kSuccess_eq_prefixRank_add_one` — the **identity**
  `k_success = rank(prefix k_success) + 1`: at the first dependence the two sides
  meet;
* `kSuccess_le_rank_add_one` — for every collected matrix `M = prefix n` with
  `n ≥ k_success`, `k_success ≤ rank(M) + 1` (so the original chain is *true* when
  `rank` means the rank of all relations collected);
* `kSuccess_le_finrank_add_one` — `k_success ≤ Q + 1`;
* `kSuccess_basis` — the bound `Q + 1` is attained (standard basis first), so the
  empirical ratios `k_success/Q ≈ 0.78/0.71/0.60` are properties of the instances,
  not of the algebra.

The bound counts **relations**, not sieve positions: nothing here bounds the
paid work, which is the number of positions needed to *find* `k_success`
relations.
-/

namespace QSPrefixRank

open Module

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V]

/-- The first `k` relation vectors, as a family indexed by `Fin k`. -/
def pre (v : ℕ → V) (k : ℕ) : Fin k → V := fun i => v i

/-- Rank of the first `k` relation vectors. -/
noncomputable def prefixRank (v : ℕ → V) (k : ℕ) : ℕ :=
  Set.finrank K (Set.range (pre v k))

omit [AddCommGroup V] [Module K V] in
theorem range_pre_mono (v : ℕ → V) {k m : ℕ} (h : k ≤ m) :
    Set.range (pre v k) ⊆ Set.range (pre v m) := by
  rintro _ ⟨i, rfl⟩
  exact ⟨⟨i, lt_of_lt_of_le i.2 h⟩, rfl⟩

theorem prefixRank_le (v : ℕ → V) (k : ℕ) : prefixRank (K := K) v k ≤ k := by
  have := finrank_range_le_card (R := K) (pre v k)
  simpa [prefixRank] using this

theorem prefixRank_mono (v : ℕ → V) {k m : ℕ} (h : k ≤ m) :
    prefixRank (K := K) v k ≤ prefixRank (K := K) v m := by
  unfold prefixRank Set.finrank
  haveI : FiniteDimensional K (Submodule.span K (Set.range (pre v m))) :=
    FiniteDimensional.span_of_finite K (Set.finite_range _)
  exact Submodule.finrank_mono (Submodule.span_mono (range_pre_mono v h))

/-- Independence of a prefix is exactly "rank = length". -/
theorem linearIndependent_pre_iff (v : ℕ → V) (k : ℕ) :
    LinearIndependent K (pre v k) ↔ prefixRank (K := K) v k = k := by
  rw [linearIndependent_iff_card_eq_finrank_span, Fintype.card_fin, prefixRank]
  exact eq_comm

/-- **Round 42's direction correction.**  A dependence at prefix `k` forces
`rank(prefix k) + 1 ≤ k`. -/
theorem prefixRank_add_one_le_of_dependent (v : ℕ → V) {k : ℕ}
    (h : ¬ LinearIndependent K (pre v k)) : prefixRank (K := K) v k + 1 ≤ k := by
  rw [linearIndependent_pre_iff] at h
  have := prefixRank_le (K := K) v k
  omega

/-- More than `dim V` relations are always dependent. -/
theorem dependent_of_finrank_lt [FiniteDimensional K V] (v : ℕ → V) {k : ℕ}
    (hk : finrank K V < k) : ¬ LinearIndependent K (pre v k) := by
  intro hli
  have := hli.fintype_card_le_finrank
  rw [Fintype.card_fin] at this
  omega

theorem exists_dependent [FiniteDimensional K V] (v : ℕ → V) :
    ∃ k, ¬ LinearIndependent K (pre v k) :=
  ⟨finrank K V + 1, dependent_of_finrank_lt v (Nat.lt_succ_self _)⟩

open Classical in
/-- `k_success`: the length of the shortest dependent prefix. -/
noncomputable def kSuccess [FiniteDimensional K V] (v : ℕ → V) : ℕ :=
  Nat.find (exists_dependent (K := K) v)

theorem kSuccess_dependent [FiniteDimensional K V] (v : ℕ → V) :
    ¬ LinearIndependent K (pre v (kSuccess (K := K) v)) := by
  classical
  exact Nat.find_spec (exists_dependent (K := K) v)

theorem independent_of_lt_kSuccess [FiniteDimensional K V] (v : ℕ → V) {k : ℕ}
    (hk : k < kSuccess (K := K) v) : LinearIndependent K (pre v k) := by
  classical
  by_contra h
  exact Nat.find_min (exists_dependent (K := K) v) hk h

theorem kSuccess_pos [FiniteDimensional K V] (v : ℕ → V) : 0 < kSuccess (K := K) v := by
  rcases Nat.eq_zero_or_pos (kSuccess (K := K) v) with h | h
  · have hd := kSuccess_dependent (K := K) v
    rw [h] at hd
    exact absurd (linearIndependent_empty_type) hd
  · exact h

/-- **The prefix-rank identity.**  `k_success = rank(prefix k_success) + 1`. -/
theorem kSuccess_eq_prefixRank_add_one [FiniteDimensional K V] (v : ℕ → V) :
    kSuccess (K := K) v = prefixRank (K := K) v (kSuccess (K := K) v) + 1 := by
  set k := kSuccess (K := K) v with hk
  have hpos : 0 < k := kSuccess_pos (K := K) v
  have hup : prefixRank (K := K) v k + 1 ≤ k :=
    prefixRank_add_one_le_of_dependent v (kSuccess_dependent (K := K) v)
  have hind : LinearIndependent K (pre v (k - 1)) :=
    independent_of_lt_kSuccess v (by omega)
  have hr : prefixRank (K := K) v (k - 1) = k - 1 := (linearIndependent_pre_iff v _).1 hind
  have hmono := prefixRank_mono (K := K) v (Nat.sub_le k 1)
  omega

/-- **The original chain, for the full collected matrix.**  If `n ≥ k_success`
relations have been collected, `k_success ≤ rank(M) + 1` where `M = prefix n`. -/
theorem kSuccess_le_rank_add_one [FiniteDimensional K V] (v : ℕ → V) {n : ℕ}
    (hn : kSuccess (K := K) v ≤ n) :
    kSuccess (K := K) v ≤ prefixRank (K := K) v n + 1 := by
  have h1 := kSuccess_eq_prefixRank_add_one (K := K) v
  have h2 := prefixRank_mono (K := K) v hn
  omega

theorem prefixRank_le_finrank [FiniteDimensional K V] (v : ℕ → V) (k : ℕ) :
    prefixRank (K := K) v k ≤ finrank K V := by
  unfold prefixRank Set.finrank
  exact Submodule.finrank_le _

/-- `k_success ≤ Q + 1` with `Q = dim V`. -/
theorem kSuccess_le_finrank_add_one [FiniteDimensional K V] (v : ℕ → V) :
    kSuccess (K := K) v ≤ finrank K V + 1 := by
  have h1 := kSuccess_eq_prefixRank_add_one (K := K) v
  have h2 := prefixRank_le_finrank (K := K) v (kSuccess (K := K) v)
  omega

/-- **Sharpness.**  In `K^Q`, if the first `Q` relations are the standard basis,
then `k_success = Q + 1`. -/
theorem kSuccess_basis (Q : ℕ) (v : ℕ → (Fin Q → K))
    (hv : ∀ i : Fin Q, v i = Pi.single i 1) :
    kSuccess (K := K) v = Q + 1 := by
  have hle := kSuccess_le_finrank_add_one (K := K) v
  rw [finrank_fin_fun] at hle
  have hind : LinearIndependent K (pre v Q) := by
    have : pre v Q = fun i : Fin Q => (Pi.basisFun K (Fin Q)) i := by
      funext i; simp [pre, hv i]
    rw [this]; exact (Pi.basisFun K (Fin Q)).linearIndependent
  by_contra hne
  have hlt : Q < kSuccess (K := K) v := by
    by_contra hge
    push_neg at hge
    have hdep := kSuccess_dependent (K := K) v
    have hsub : LinearIndependent K (pre v (kSuccess (K := K) v)) := by
      have hcomp : pre v (kSuccess (K := K) v) =
          pre v Q ∘ Fin.castLE hge := by funext i; rfl
      rw [hcomp]; exact hind.comp _ (Fin.castLE_injective hge)
    exact hdep hsub
  omega

/-! ## Specialisation to the quadratic sieve: `Q(N,B) + 1` relations -/

/-- **QS form.**  For relation vectors in `𝔽₂^{A}`, `A` the admissible primes of
`N` at bound `B`, the first dependence occurs after at most `Q(N,B) + 1`
relations, and exactly one more than the rank of the prefix it closes. -/
theorem qs_kSuccess_bounds (N : ℤ) (B : ℕ)
    (v : ℕ → (QSDimension.admissiblePrimes N B → ZMod 2)) :
    kSuccess (K := ZMod 2) v = prefixRank (K := ZMod 2) v (kSuccess (K := ZMod 2) v) + 1 ∧
    kSuccess (K := ZMod 2) v ≤ (QSDimension.admissiblePrimes N B).card + 1 := by
  refine ⟨kSuccess_eq_prefixRank_add_one v, ?_⟩
  have := kSuccess_le_finrank_add_one (K := ZMod 2) v
  rwa [Module.finrank_fintype_fun_eq_card, Fintype.card_coe] at this

end QSPrefixRank