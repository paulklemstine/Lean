import Bridges.MoonshineMomentLaurentBridge
import Bridges.MoonshineBellTransitivityBridge

/-!
# Moonshine beyond the j-function IV: moments determine the trace distribution

This file closes **Conjecture A** of the previous cycles of this research thread
(`Catalog/Bridges/MoonshineMomentLaurentBridge.lean`,
`Catalog/Bridges/MoonshineBellTransitivityBridge.lean`, `FUTURE_DIRECTIONS.md`).

Cycle 1 proved the *moment hierarchy*

  `∑_{g ∈ G} |X^g| ^ k = |G| · #((Fin k → X)/G)`

for every `k`, and cycle 2 identified its extremal case (`k`-transitivity, Bell numbers).
Conjecture A asked the inverse question: *do the orbit counts on `k`-tuples, for `k` in a finite
range, already determine the whole distribution of the fixed-point (trace) function
`g ↦ |X^g|`?*  The answer proved here is **yes**, with the range `k ≤ N` where `N` bounds the
sizes of the underlying sets — and that range is sharp.

## Structure of the argument

* `powerSum_eq_sum_fiber` rewrites a power sum `∑ i, f i ^ k` of an `ℕ`-valued function bounded
  by `N` as `∑_{v ≤ N} (#f⁻¹(v)) · v ^ k`, i.e. as a linear functional of the *counting vector*.
* `count_eq_of_powerSums` inverts this linear system: the matrix `(v ^ k)_{k,v ≤ N}` is a
  transposed Vandermonde matrix with the distinct nodes `0, 1, …, N`, hence invertible over `ℚ`,
  so the counting vector is determined by the power sums `k = 0, 1, …, N`.  This is the
  finite-dimensional core of the conjecture: *finitely many moments of a bounded `ℕ`-valued
  function determine its distribution.*
* `valueMultiset_eq_iff_powerSums` packages this as an equivalence between equality of value
  multisets and equality of the first `N + 1` power sums.
* `powerSums_not_determined_of_lt` shows the range cannot be shortened: two functions bounded by
  `2` with equal power sums for `k ≤ 1` but different distributions.
* `traceDistribution_eq_iff_card_orbits_eq` is the moonshine statement: two finite `G`-actions
  have the same trace distribution **iff** they have the same number of orbits on `k`-tuples for
  all `k ≤ N` (equivalently, for all `k`).
* Consequences: the number of fixed-point-free elements, the orbit count, and — combining with
  cycle 2's Bell criterion — the whole `k`-transitivity spectrum are invariants of the trace
  distribution (`card_free_elements_eq`, `card_orbits_eq_of_traceDistribution`,
  `kTransitive_iff_of_traceDistribution_eq`).
* A graded (q-series) version transfers the statement to each coefficient of the trace series
  (`traceDistribution_graded_eq`, `moment_series_eq_of_traceDistribution_eq`).

Everything is proved; there are no `sorry`s, no `native_decide`, and no new axioms.
-/

open Finset MulAction Matrix

namespace MoonshineDistribution

/-! ## Part 1: power sums of a bounded `ℕ`-valued function -/

section PowerSums

variable {ι κ : Type*}

/-- The multiset of values of a function on a finite type: its *distribution*, with
multiplicities. -/
def valueMultiset [Fintype ι] (a : ι → ℕ) : Multiset ℕ := (univ : Finset ι).val.map a

theorem count_valueMultiset [Fintype ι] [DecidableEq ι] (a : ι → ℕ) (v : ℕ) :
    (valueMultiset a).count v = #{i | a i = v} := by
  simp [valueMultiset, Multiset.count_map, Finset.card, Finset.filter, eq_comm]

theorem valueMultiset_ext [Fintype ι] [Fintype κ] [DecidableEq ι] [DecidableEq κ]
    {a : ι → ℕ} {b : κ → ℕ} (h : ∀ v, #{i | a i = v} = #{j | b j = v}) :
    valueMultiset a = valueMultiset b := by
  refine Multiset.ext.2 fun v => ?_
  rw [count_valueMultiset, count_valueMultiset, h]

/-- A power sum of a bounded `ℕ`-valued function is a linear functional of its counting
vector. -/
theorem powerSum_eq_sum_fiber [Fintype ι] [DecidableEq ι] (N : ℕ) (f : ι → ℕ)
    (hf : ∀ i, f i ≤ N) (k : ℕ) :
    ((∑ i, f i ^ k : ℕ) : ℚ)
      = ∑ w : Fin (N + 1), ((#{i | f i = (w : ℕ)} : ℕ) : ℚ) * ((w : ℕ) : ℚ) ^ k := by
  have hmaps : ∀ i ∈ (univ : Finset ι),
      (⟨f i, Nat.lt_succ_of_le (hf i)⟩ : Fin (N + 1)) ∈ (univ : Finset (Fin (N + 1))) :=
    fun i _ => mem_univ _
  have hfib := Finset.sum_fiberwise_of_maps_to hmaps (fun i => ((f i : ℚ)) ^ k)
  push_cast
  rw [← hfib]
  refine Finset.sum_congr rfl fun w _ => ?_
  have hconst : ∀ i ∈ (univ.filter
      (fun i => (⟨f i, Nat.lt_succ_of_le (hf i)⟩ : Fin (N + 1)) = w)),
      ((f i : ℚ)) ^ k = ((w : ℕ) : ℚ) ^ k := by
    intro i hi
    simp only [mem_filter, Fin.ext_iff] at hi
    rw [hi.2]
  rw [Finset.sum_congr rfl hconst, Finset.sum_const, nsmul_eq_mul]
  congr 2
  apply Finset.card_nbij id <;>
    simp [Fin.ext_iff, Set.InjOn, Set.SurjOn, Set.MapsTo]

/-- **Power-sum inversion (Conjecture A, finite-dimensional core).**  Two `ℕ`-valued functions on
finite types, both bounded by `N`, with the same power sums `∑ a i ^ k` for all `k ≤ N`, have the
same distribution of values.  The proof inverts a transposed Vandermonde system with the `N + 1`
distinct nodes `0, 1, …, N`. -/
theorem count_eq_of_powerSums [Fintype ι] [Fintype κ] [DecidableEq ι] [DecidableEq κ]
    (a : ι → ℕ) (b : κ → ℕ) (N : ℕ) (ha : ∀ i, a i ≤ N) (hb : ∀ j, b j ≤ N)
    (h : ∀ k ≤ N, ∑ i, a i ^ k = ∑ j, b j ^ k) (v : ℕ) :
    #{i | a i = v} = #{j | b j = v} := by
  by_cases hv : v ≤ N
  · set c : Fin (N + 1) → ℚ := fun w => ((#{i | a i = (w : ℕ)} : ℕ) : ℚ) with hc
    set d : Fin (N + 1) → ℚ := fun w => ((#{j | b j = (w : ℕ)} : ℕ) : ℚ) with hd
    have hfinj : Function.Injective (fun w : Fin (N + 1) => ((w : ℕ) : ℚ)) := by
      intro w₁ w₂ hw
      have hw' : ((w₁ : ℕ) : ℚ) = ((w₂ : ℕ) : ℚ) := hw
      exact Fin.ext (by exact_mod_cast hw')
    set M : Matrix (Fin (N + 1)) (Fin (N + 1)) ℚ :=
      (Matrix.vandermonde (fun w : Fin (N + 1) => ((w : ℕ) : ℚ)))ᵀ with hM
    have hdet : M.det ≠ 0 := by
      rw [hM, Matrix.det_transpose]
      exact Matrix.det_vandermonde_ne_zero_iff.2 hfinj
    have hunit : IsUnit M := (Matrix.isUnit_iff_isUnit_det M).2 (isUnit_iff_ne_zero.2 hdet)
    have hmul : M *ᵥ c = M *ᵥ d := by
      funext k
      have hka := powerSum_eq_sum_fiber N a ha (k : ℕ)
      have hkb := powerSum_eq_sum_fiber N b hb (k : ℕ)
      have hk : ((∑ i, a i ^ (k : ℕ) : ℕ) : ℚ) = ((∑ j, b j ^ (k : ℕ) : ℕ) : ℚ) := by
        exact_mod_cast congrArg (Nat.cast : ℕ → ℚ) (h k (Nat.lt_succ_iff.1 k.isLt))
      simp only [Matrix.mulVec, dotProduct, hM, Matrix.transpose_apply,
        Matrix.vandermonde_apply, hc, hd]
      calc ∑ w : Fin (N + 1), ((w : ℕ) : ℚ) ^ (k : ℕ) * ((#{i | a i = (w : ℕ)} : ℕ) : ℚ)
          = ∑ w : Fin (N + 1), ((#{i | a i = (w : ℕ)} : ℕ) : ℚ) * ((w : ℕ) : ℚ) ^ (k : ℕ) :=
            Finset.sum_congr rfl fun w _ => mul_comm _ _
        _ = ((∑ i, a i ^ (k : ℕ) : ℕ) : ℚ) := hka.symm
        _ = ((∑ j, b j ^ (k : ℕ) : ℕ) : ℚ) := hk
        _ = ∑ w : Fin (N + 1), ((#{j | b j = (w : ℕ)} : ℕ) : ℚ) * ((w : ℕ) : ℚ) ^ (k : ℕ) := hkb
        _ = ∑ w : Fin (N + 1), ((w : ℕ) : ℚ) ^ (k : ℕ) * ((#{j | b j = (w : ℕ)} : ℕ) : ℚ) :=
            Finset.sum_congr rfl fun w _ => mul_comm _ _
    have hcd : c = d := Matrix.mulVec_injective_of_isUnit hunit hmul
    have hv' := congrFun hcd (⟨v, Nat.lt_succ_of_le hv⟩ : Fin (N + 1))
    simp only [hc, hd] at hv'
    exact_mod_cast hv'
  · have h1 : ({i | a i = v} : Finset ι) = ∅ :=
      Finset.filter_eq_empty_iff.2 fun i _ hi => hv (hi ▸ ha i)
    have h2 : ({j | b j = v} : Finset κ) = ∅ :=
      Finset.filter_eq_empty_iff.2 fun j _ hj => hv (hj ▸ hb j)
    rw [h1, h2]
    rfl

/-- Distribution form of power-sum inversion. -/
theorem valueMultiset_eq_of_powerSums [Fintype ι] [Fintype κ]
    (a : ι → ℕ) (b : κ → ℕ) (N : ℕ) (ha : ∀ i, a i ≤ N) (hb : ∀ j, b j ≤ N)
    (h : ∀ k ≤ N, ∑ i, a i ^ k = ∑ j, b j ^ k) :
    valueMultiset a = valueMultiset b := by
  classical
  exact valueMultiset_ext (count_eq_of_powerSums a b N ha hb h)

/-- Relabelling the index set does not change the distribution. -/
theorem valueMultiset_comp_equiv [Fintype ι] [Fintype κ] (e : κ ≃ ι) (a : ι → ℕ) :
    valueMultiset (a ∘ e) = valueMultiset a := by
  have h : (univ : Finset κ).map e.toEmbedding = univ := Finset.map_univ_equiv e
  calc valueMultiset (a ∘ e) = ((univ : Finset κ).val.map e).map a := by
        rw [valueMultiset, Multiset.map_map]
    _ = ((univ : Finset κ).map e.toEmbedding).val.map a := rfl
    _ = valueMultiset a := by rw [h]; rfl

/-- The easy converse: equal distributions give equal power sums, for *every* exponent. -/
theorem powerSum_eq_of_valueMultiset_eq [Fintype ι] [Fintype κ] {a : ι → ℕ} {b : κ → ℕ}
    (h : valueMultiset a = valueMultiset b) (k : ℕ) :
    ∑ i, a i ^ k = ∑ j, b j ^ k := by
  have h' : ((valueMultiset a).map (fun v => v ^ k)).sum
      = ((valueMultiset b).map (fun v => v ^ k)).sum := by rw [h]
  have ea : ((valueMultiset a).map (fun v => v ^ k)).sum = ∑ i, a i ^ k := by
    rw [valueMultiset, Multiset.map_map]
    rfl
  have eb : ((valueMultiset b).map (fun v => v ^ k)).sum = ∑ j, b j ^ k := by
    rw [valueMultiset, Multiset.map_map]
    rfl
  rw [ea, eb] at h'
  exact h'

/-- **Moments ⟺ distribution.**  For `ℕ`-valued functions bounded by `N`, equality of the value
distributions is equivalent to equality of the first `N + 1` power sums. -/
theorem valueMultiset_eq_iff_powerSums [Fintype ι] [Fintype κ]
    (a : ι → ℕ) (b : κ → ℕ) (N : ℕ) (ha : ∀ i, a i ≤ N) (hb : ∀ j, b j ≤ N) :
    valueMultiset a = valueMultiset b ↔ ∀ k ≤ N, ∑ i, a i ^ k = ∑ j, b j ^ k :=
  ⟨fun h k _ => powerSum_eq_of_valueMultiset_eq h k,
   fun h => valueMultiset_eq_of_powerSums a b N ha hb h⟩

/-- **Sharpness of the range.**  Knowing the power sums only for `k < N` is not enough: the
functions `(0, 2)` and `(1, 1)`, both bounded by `2`, have equal power sums for `k ≤ 1` but
different distributions.  So the bound `k ≤ N` in `count_eq_of_powerSums` cannot be lowered in
general. -/
theorem powerSums_not_determined_of_lt :
    ∃ a b : Fin 2 → ℕ, (∀ i, a i ≤ 2) ∧ (∀ i, b i ≤ 2) ∧
      (∀ k ≤ 1, ∑ i, a i ^ k = ∑ i, b i ^ k) ∧ valueMultiset a ≠ valueMultiset b := by
  refine ⟨![0, 2], ![1, 1], by decide, by decide, ?_, ?_⟩
  · intro k hk
    interval_cases k <;> decide
  · intro hcontra
    have h := congrArg (fun s => Multiset.count 1 s) hcontra
    simp [valueMultiset] at h

end PowerSums

/-! ## Part 2: the moonshine statement — trace distributions and orbit counts -/

section TraceDistribution

/-- The **trace distribution** of a finite `G`-action: the multiset of the values
`|X^g| = #fixedBy X g`, `g ∈ G`.  These are exactly the coefficients, at a fixed grade, of the
element-indexed trace ("McKay–Thompson"-style) series of this thread. -/
noncomputable def traceDistribution (G : Type*) [Group G] [Fintype G] (X : Type*)
    [MulAction G X] : Multiset ℕ :=
  valueMultiset (fun g : G => Nat.card (fixedBy X g))

theorem card_fixedBy_le {G : Type*} [Group G] {X : Type*} [MulAction G X] [Finite X] (g : G) :
    Nat.card (fixedBy X g) ≤ Nat.card X :=
  Nat.card_le_card_of_injective _ Subtype.val_injective

variable (G : Type*) [Group G] [Fintype G]
variable (X : Type*) [MulAction G X] [Finite X]
variable (Y : Type*) [MulAction G Y] [Finite Y]

/-- **Conjecture A, moonshine form.**  Two finite `G`-actions with the same number of orbits on
`k`-tuples for every `k ≤ N` (where `N` bounds both sets) have the *same* trace distribution:
the multisets `{|X^g| : g ∈ G}` and `{|Y^g| : g ∈ G}` coincide. -/
theorem traceDistribution_eq_of_card_orbits_eq (N : ℕ) (hX : Nat.card X ≤ N) (hY : Nat.card Y ≤ N)
    (h : ∀ k ≤ N, Nat.card (orbitRel.Quotient G (Fin k → X))
      = Nat.card (orbitRel.Quotient G (Fin k → Y))) :
    traceDistribution G X = traceDistribution G Y := by
  refine valueMultiset_eq_of_powerSums _ _ N (fun g => (card_fixedBy_le g).trans hX)
    (fun g => (card_fixedBy_le g).trans hY) ?_
  intro k hk
  rw [MoonshineMoments.sum_fixedPoints_pow_eq_orbits_mul_card G X k,
    MoonshineMoments.sum_fixedPoints_pow_eq_orbits_mul_card G Y k, h k hk]

/-- Converse direction: the trace distribution determines every orbit count on tuples. -/
theorem card_orbits_eq_of_traceDistribution_eq (h : traceDistribution G X = traceDistribution G Y)
    (k : ℕ) :
    Nat.card (orbitRel.Quotient G (Fin k → X)) = Nat.card (orbitRel.Quotient G (Fin k → Y)) := by
  have hk := powerSum_eq_of_valueMultiset_eq h k
  rw [MoonshineMoments.sum_fixedPoints_pow_eq_orbits_mul_card G X k,
    MoonshineMoments.sum_fixedPoints_pow_eq_orbits_mul_card G Y k] at hk
  exact Nat.eq_of_mul_eq_mul_right Nat.card_pos hk

/-- **Equivalence.**  For finite `G`-actions bounded by `N`, the trace distribution and the orbit
counts on `k`-tuples (`k ≤ N`) carry exactly the same information. -/
theorem traceDistribution_eq_iff_card_orbits_eq (N : ℕ) (hX : Nat.card X ≤ N)
    (hY : Nat.card Y ≤ N) :
    traceDistribution G X = traceDistribution G Y ↔
      ∀ k ≤ N, Nat.card (orbitRel.Quotient G (Fin k → X))
        = Nat.card (orbitRel.Quotient G (Fin k → Y)) :=
  ⟨fun h k _ => card_orbits_eq_of_traceDistribution_eq G X Y h k,
   traceDistribution_eq_of_card_orbits_eq G X Y N hX hY⟩

/-- Finitely many moments propagate to all moments: agreement for `k ≤ N` forces agreement for
every `k`. -/
theorem card_orbits_eq_of_le (N : ℕ) (hX : Nat.card X ≤ N) (hY : Nat.card Y ≤ N)
    (h : ∀ k ≤ N, Nat.card (orbitRel.Quotient G (Fin k → X))
      = Nat.card (orbitRel.Quotient G (Fin k → Y))) (k : ℕ) :
    Nat.card (orbitRel.Quotient G (Fin k → X)) = Nat.card (orbitRel.Quotient G (Fin k → Y)) :=
  card_orbits_eq_of_traceDistribution_eq G X Y
    (traceDistribution_eq_of_card_orbits_eq G X Y N hX hY h) k

end TraceDistribution

/-! ## Part 3: invariants read off the trace distribution -/

section Invariants

variable (G : Type*) [Group G] [Fintype G]
variable (X : Type*) [MulAction G X]
variable (Y : Type*) [MulAction G Y]

/-- Every level set of the fixed-point counting function has the same size for two actions with
the same trace distribution. -/
theorem card_level_eq (h : traceDistribution G X = traceDistribution G Y) (v : ℕ) :
    #{g : G | Nat.card (fixedBy X g) = v} = #{g : G | Nat.card (fixedBy Y g) = v} := by
  classical
  have hcount := congrArg (fun s => Multiset.count v s) h
  simpa [traceDistribution, count_valueMultiset] using hcount

/-- In particular the number of elements acting without fixed points ("fixed-point-free
elements", the vanishing locus of the leading trace coefficient) is an invariant of the trace
distribution. -/
theorem card_free_elements_eq (h : traceDistribution G X = traceDistribution G Y) :
    #{g : G | Nat.card (fixedBy X g) = 0} = #{g : G | Nat.card (fixedBy Y g) = 0} :=
  card_level_eq G X Y h 0

variable [Finite X] [Finite Y]

/-- **Cross-cycle corollary.**  Combined with the Bell-number criterion of cycle 2, the trace
distribution determines the entire `k`-transitivity spectrum of the action. -/
theorem kTransitive_iff_of_traceDistribution_eq (h : traceDistribution G X = traceDistribution G Y)
    (k : ℕ) (hkX : k ≤ Nat.card X) (hkY : k ≤ Nat.card Y) :
    MoonshineBell.KTransitive k G X ↔ MoonshineBell.KTransitive k G Y := by
  rw [← MoonshineBell.sum_fixedPoints_pow_eq_bell_mul_card_iff k G X hkX,
    ← MoonshineBell.sum_fixedPoints_pow_eq_bell_mul_card_iff k G Y hkY,
    powerSum_eq_of_valueMultiset_eq h k]

/-- In particular transitivity itself (`k = 1`) is determined. -/
theorem transitive_iff_of_traceDistribution_eq (h : traceDistribution G X = traceDistribution G Y)
    (hX : 1 ≤ Nat.card X) (hY : 1 ≤ Nat.card Y) :
    MoonshineBell.KTransitive 1 G X ↔ MoonshineBell.KTransitive 1 G Y :=
  kTransitive_iff_of_traceDistribution_eq G X Y h 1 hX hY

/-- The number of orbits (Burnside's count) is determined by the trace distribution. -/
theorem card_orbits_eq_of_traceDistribution (h : traceDistribution G X = traceDistribution G Y) :
    Nat.card (orbitRel.Quotient G X) = Nat.card (orbitRel.Quotient G Y) := by
  have h1 : ∑ g : G, Nat.card (fixedBy X g) = ∑ g : G, Nat.card (fixedBy Y g) := by
    simpa using powerSum_eq_of_valueMultiset_eq h 1
  rw [MoonshineMoments.sum_card_fixedBy_eq_orbits_mul_card G X,
    MoonshineMoments.sum_card_fixedBy_eq_orbits_mul_card G Y] at h1
  exact Nat.eq_of_mul_eq_mul_right Nat.card_pos h1

end Invariants

/-! ## Part 4: graded (q-series) form -/

section Graded

variable (G : Type*) [Group G] [Fintype G]
variable (X : ℕ → Type*) [∀ n, MulAction G (X n)] [∀ n, Finite (X n)]
variable (Y : ℕ → Type*) [∀ n, MulAction G (Y n)] [∀ n, Finite (Y n)]

/-- **Graded Conjecture A.**  If two graded finite `G`-sets have, at each grade `n`, the same
orbit counts on `k`-tuples for `k ≤ N n`, then at each grade the coefficients of the trace series
`T_g(q)` have the same distribution over `G`.  Grade by grade, the family of q-series is
determined up to relabelling by the moment data. -/
theorem traceDistribution_graded_eq (N : ℕ → ℕ)
    (hX : ∀ n, Nat.card (X n) ≤ N n) (hY : ∀ n, Nat.card (Y n) ≤ N n)
    (h : ∀ n, ∀ k ≤ N n, Nat.card (orbitRel.Quotient G (Fin k → X n))
      = Nat.card (orbitRel.Quotient G (Fin k → Y n))) (n : ℕ) :
    traceDistribution G (X n) = traceDistribution G (Y n) :=
  traceDistribution_eq_of_card_orbits_eq G (X n) (Y n) (N n) (hX n) (hY n) (h n)

omit [∀ n, Finite (X n)] [∀ n, Finite (Y n)] in
/-- Gradewise, equal trace distributions give equal moment series in every exponent `k`; i.e. the
`k`-th moment q-series `n ↦ ∑_g T_g(n)^k` of the two families coincide. -/
theorem moment_series_eq_of_traceDistribution_eq
    (h : ∀ n, traceDistribution G (X n) = traceDistribution G (Y n)) (k n : ℕ) :
    ∑ g : G, Nat.card (fixedBy (X n) g) ^ k = ∑ g : G, Nat.card (fixedBy (Y n) g) ^ k :=
  powerSum_eq_of_valueMultiset_eq (h n) k

end Graded

/-! ## Part 5: the limits of the invariant

The trace distribution is a *complete* invariant for the moment data (Part 2), but it is **not**
a complete invariant of the action itself.  The Klein four-group `Perm (Fin 2) × Perm (Fin 2)`
acting on two points through its first, resp. second, factor gives two actions with identical
trace distributions — hence identical orbit counts on `k`-tuples for every `k` — that are not
isomorphic as `G`-sets (their kernels differ).  So no amount of moment data can recover the
action: exactly the phenomenon behind the "a single aggregate loses information" warning of
cycle 1. -/

section Limits

/-- The Klein four-group, presented so that it has two visible actions on a two-point set. -/
abbrev Klein : Type := Equiv.Perm (Fin 2) × Equiv.Perm (Fin 2)

/-- Two points, acted on through the **first** factor. -/
def FstPoint : Type := Fin 2

/-- Two points, acted on through the **second** factor. -/
def SndPoint : Type := Fin 2

instance : Fintype FstPoint := inferInstanceAs (Fintype (Fin 2))
instance : Fintype SndPoint := inferInstanceAs (Fintype (Fin 2))
instance : DecidableEq FstPoint := inferInstanceAs (DecidableEq (Fin 2))
instance : DecidableEq SndPoint := inferInstanceAs (DecidableEq (Fin 2))

instance : MulAction Klein FstPoint where
  smul g x := (g.1 : Equiv.Perm (Fin 2)) (x : Fin 2)
  one_smul _ := rfl
  mul_smul _ _ _ := rfl

instance : MulAction Klein SndPoint where
  smul g x := (g.2 : Equiv.Perm (Fin 2)) (x : Fin 2)
  one_smul _ := rfl
  mul_smul _ _ _ := rfl

/-- The first of the two points. -/
def p0 : FstPoint := (0 : Fin 2)

/-- The second of the two points. -/
def p1 : FstPoint := (1 : Fin 2)

theorem card_fixedBy_fst_eq_snd_swap (g : Klein) :
    Nat.card (fixedBy FstPoint g) = Nat.card (fixedBy SndPoint (Prod.swap g)) := rfl

/-- The two Klein actions have the *same* trace distribution: swapping the two factors is a
bijection of the group carrying one fixed-point function to the other. -/
theorem traceDistribution_fst_eq_snd :
    traceDistribution Klein FstPoint = traceDistribution Klein SndPoint := by
  have h : (fun g : Klein => Nat.card (fixedBy SndPoint g)) ∘ (Equiv.prodComm _ _)
      = fun g : Klein => Nat.card (fixedBy FstPoint g) := by
    funext g
    exact (card_fixedBy_fst_eq_snd_swap g).symm
  calc traceDistribution Klein FstPoint
      = valueMultiset ((fun g : Klein => Nat.card (fixedBy SndPoint g)) ∘ (Equiv.prodComm _ _)) := by
        rw [h]; rfl
    _ = traceDistribution Klein SndPoint :=
        valueMultiset_comp_equiv (Equiv.prodComm _ _) _

/-- Consequently the two actions have the same number of orbits on `k`-tuples for every `k`. -/
theorem card_orbits_fst_eq_snd (k : ℕ) :
    Nat.card (orbitRel.Quotient Klein (Fin k → FstPoint))
      = Nat.card (orbitRel.Quotient Klein (Fin k → SndPoint)) :=
  card_orbits_eq_of_traceDistribution_eq Klein FstPoint SndPoint traceDistribution_fst_eq_snd k

/-- Yet the two actions are **not** isomorphic: there is no equivariant bijection between them,
because `(swap, 1)` moves every point of `FstPoint` and fixes every point of `SndPoint`. -/
theorem not_equivariant_equiv_fst_snd :
    ¬ ∃ e : FstPoint ≃ SndPoint, ∀ (g : Klein) (x : FstPoint), e (g • x) = g • e x := by
  rintro ⟨e, he⟩
  have h := he (Equiv.swap (0 : Fin 2) 1, 1) p0
  have hs : (Equiv.swap (0 : Fin 2) 1, (1 : Equiv.Perm (Fin 2))) • p0 = p1 := by decide
  have h2 : ((Equiv.swap (0 : Fin 2) 1, (1 : Equiv.Perm (Fin 2))) • e p0 : SndPoint) = e p0 := rfl
  rw [hs, h2] at h
  have hne : p1 ≠ p0 := by decide
  exact hne (e.injective h)

/-- **The moment data is complete for distributions but not for actions.**  There are two finite
actions of one finite group with equal trace distributions (hence equal orbit counts on
`k`-tuples for all `k`) which are not equivariantly isomorphic. -/
theorem traceDistribution_not_complete_invariant :
    traceDistribution Klein FstPoint = traceDistribution Klein SndPoint ∧
      (∀ k : ℕ, Nat.card (orbitRel.Quotient Klein (Fin k → FstPoint))
        = Nat.card (orbitRel.Quotient Klein (Fin k → SndPoint))) ∧
      ¬ ∃ e : FstPoint ≃ SndPoint, ∀ (g : Klein) (x : FstPoint), e (g • x) = g • e x :=
  ⟨traceDistribution_fst_eq_snd, card_orbits_fst_eq_snd, not_equivariant_equiv_fst_snd⟩

end Limits

end MoonshineDistribution