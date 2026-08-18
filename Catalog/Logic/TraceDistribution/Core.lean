/-
# Conjecture A, closed: trace distributions of finite group actions

Let `G` be a finite group acting on a finite set `X`.  Two invariants compete for the
role of "the" combinatorial shadow of the action:

* the **trace distribution** `traceDistribution G X = {| X^g | : g ∈ G}`, the multiset
  of fixed-point counts (equivalently, the permutation character of the action, taken
  as an unordered multiset rather than as a class function);
* the **orbit spectrum** `k ↦ orbitCount G X k`, the number of `G`-orbits on the set
  `X^k` of `k`-tuples (`Fin k → X`).

The main results of this file prove that the two invariants are *equivalent*, and that
the equivalence is already witnessed by a finite, explicitly bounded, range of `k`:

* `orbitCount_mul_card_group` — Burnside's lemma in the graded form
  `|orbits on X^k| · |G| = ∑_{g ∈ G} |X^g|^k`, i.e. the orbit spectrum is exactly the
  sequence of **power sums** of the trace distribution.
* `traceDistribution_eq_iff_card_orbits_eq` — **the main theorem.** Two actions have
  the same trace distribution **iff** they have the same orbit counts on `k`-tuples
  for all `k ≤ max (|X|) (|Y|)`.
* `card_orbits_eq_of_le` — the finite range of `k` already forces agreement for
  *every* `k`: the orbit spectrum is a *rigid* sequence.
* `traceDistribution_graded_eq` — the gradewise q-series form: the fixed-point
  generating polynomial `∑_{g ∈ G} q^{|X^g|} ∈ ℤ[q]` is a complete invariant, and it
  agrees for `X` and `Y` iff the finitely many orbit counts do.

The bridge from "equal power sums" to "equal multisets" is `multiset_eq_of_powerSum_eq`,
proved in `Logic.TraceDistribution.PowerSums` by Lagrange-interpolation duality.

## Lab notes (experimental data)

* `G = ℤ/2` acting on `X = ℤ/2` by translation: `traceDistribution = {2, 0}`,
  orbit counts `1, 1, 2, 4, 8, …` (`= (2^k + 0^k)/2`).
* `G = ℤ/2` acting trivially on a 1-point set `Y`: `traceDistribution = {1, 1}`,
  orbit counts `1, 1, 1, 1, …`.  The two are separated already at `k = 2`
  (`2 ≠ 1`), well inside the bound `max(2,1) = 2`.
* The bound is *not* vacuous: `k = 0` always gives `orbitCount = 1` for both actions
  and `k = 1` gives the plain orbit count, so genuinely higher `k` is needed.
-/
import Mathlib
import Logic.TraceDistribution.PowerSums

open MulAction Finset

namespace TraceDistribution

/-! ## Definitions -/

/-- `fixedCard X g = |X^g|`, the number of points of `X` fixed by `g`. -/
noncomputable def fixedCard {G : Type*} [Group G] (X : Type*) [MulAction G X] (g : G) : ℕ :=
  Nat.card (fixedBy X g)

/-- The **trace distribution** of a finite `G`-action: the multiset `{|X^g| : g ∈ G}`,
indexed by the group elements (so its cardinality is always `|G|`). -/
noncomputable def traceDistribution (G : Type*) [Group G] [Fintype G]
    (X : Type*) [MulAction G X] : Multiset ℕ :=
  (Finset.univ : Finset G).val.map (fixedCard X)

/-- `orbitCount G X k` is the number of `G`-orbits on the set `X^k` of `k`-tuples. -/
noncomputable def orbitCount (G : Type*) [Group G] (X : Type*) [MulAction G X] (k : ℕ) : ℕ :=
  Nat.card (Quotient (orbitRel G (Fin k → X)))

/-- The gradewise **q-series** (fixed-point generating polynomial) of the action:
`∑_{g ∈ G} q^{|X^g|} ∈ ℤ[q]`. -/
noncomputable def traceSeries (G : Type*) [Group G] [Fintype G]
    (X : Type*) [MulAction G X] : Polynomial ℤ :=
  ∑ g : G, (Polynomial.X : Polynomial ℤ) ^ (fixedCard X g)

/-! ## Burnside's lemma, graded over tuple length -/

/-- Burnside's lemma in `Nat.card` form. -/
theorem burnside (G : Type*) [Group G] [Fintype G] (β : Type*) [MulAction G β] [Finite β] :
    ∑ g : G, fixedCard β g = Nat.card (Quotient (orbitRel G β)) * Nat.card G := by
  classical
  have _ := Fintype.ofFinite β
  have _ := Fintype.ofFinite (Quotient (orbitRel G β))
  simp only [fixedCard, Nat.card_eq_fintype_card]
  exact MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group G β

/-- A `k`-tuple is fixed by `g` exactly when each of its entries is: this is the
"tensor power" structure that turns Burnside's lemma into a power-sum statement. -/
def fixedByPiEquiv {G : Type*} [Group G] (X : Type*) [MulAction G X] (g : G) (k : ℕ) :
    fixedBy (Fin k → X) g ≃ (Fin k → fixedBy X g) where
  toFun f i := ⟨f.1 i, by
    have h := f.2
    rw [mem_fixedBy] at h ⊢
    exact congrFun h i⟩
  invFun f := ⟨fun i => (f i).1, by
    rw [mem_fixedBy]; funext i; exact (f i).2⟩
  left_inv f := by ext i; rfl
  right_inv f := by ext i; rfl

/-- `|(X^k)^g| = |X^g|^k`. -/
theorem fixedCard_pi {G : Type*} [Group G] (X : Type*) [MulAction G X] [Finite X]
    (g : G) (k : ℕ) : fixedCard (Fin k → X) g = (fixedCard X g) ^ k := by
  unfold fixedCard
  rw [Nat.card_congr (fixedByPiEquiv X g k)]
  simp [Nat.card_pi]

theorem powerSum_traceDistribution (G : Type*) [Group G] [Fintype G]
    (X : Type*) [MulAction G X] (k : ℕ) :
    (Multiset.map (fun a => a ^ k) (traceDistribution G X)).sum
      = ∑ g : G, (fixedCard X g) ^ k := by
  rw [traceDistribution, Multiset.map_map]
  rfl

/-- **Graded Burnside lemma.** The number of orbits on `k`-tuples, times `|G|`, is the
`k`-th power sum of the trace distribution. -/
theorem orbitCount_mul_card_group (G : Type*) [Group G] [Fintype G]
    (X : Type*) [MulAction G X] [Finite X] (k : ℕ) :
    orbitCount G X k * Nat.card G
      = (Multiset.map (fun a => a ^ k) (traceDistribution G X)).sum := by
  rw [powerSum_traceDistribution, orbitCount, ← burnside G (Fin k → X)]
  refine Finset.sum_congr rfl fun g _ => ?_
  exact fixedCard_pi (G := G) X g k

/-! ## Elementary structure of the trace distribution -/

theorem fixedCard_le {G : Type*} [Group G] (X : Type*) [MulAction G X] [Finite X] (g : G) :
    fixedCard X g ≤ Nat.card X :=
  Nat.card_le_card_of_injective _ Subtype.val_injective

theorem fixedCard_one {G : Type*} [Group G] (X : Type*) [MulAction G X] :
    fixedCard X (1 : G) = Nat.card X := by
  rw [fixedCard, fixedBy_one_eq_univ X G]
  exact Nat.card_congr (Equiv.Set.univ X)

theorem exists_of_mem_traceDistribution {G : Type*} [Group G] [Fintype G] (X : Type*)
    [MulAction G X] {a : ℕ} (h : a ∈ traceDistribution G X) : ∃ g : G, fixedCard X g = a := by
  rw [traceDistribution] at h
  obtain ⟨g, _, hg⟩ := Multiset.mem_map.mp h
  exact ⟨g, hg⟩

theorem card_mem_traceDistribution (G : Type*) [Group G] [Fintype G] (X : Type*)
    [MulAction G X] : Nat.card X ∈ traceDistribution G X := by
  rw [traceDistribution]
  exact Multiset.mem_map.mpr ⟨1, Finset.mem_univ_val 1, fixedCard_one X⟩

theorem le_card_of_mem_traceDistribution {G : Type*} [Group G] [Fintype G] (X : Type*)
    [MulAction G X] [Finite X] {a : ℕ} (h : a ∈ traceDistribution G X) : a ≤ Nat.card X := by
  obtain ⟨g, rfl⟩ := exists_of_mem_traceDistribution X h
  exact fixedCard_le X g

/-- The trace distribution knows the size of the set it came from: `|X|` is its largest
entry, realised at the identity. -/
theorem card_eq_of_traceDistribution_eq {G : Type*} [Group G] [Fintype G]
    (X Y : Type*) [MulAction G X] [MulAction G Y] [Finite X] [Finite Y]
    (h : traceDistribution G X = traceDistribution G Y) : Nat.card X = Nat.card Y := by
  have h1 : Nat.card X ≤ Nat.card Y :=
    le_card_of_mem_traceDistribution Y (h ▸ card_mem_traceDistribution G X)
  have h2 : Nat.card Y ≤ Nat.card X :=
    le_card_of_mem_traceDistribution X (h.symm ▸ card_mem_traceDistribution G Y)
  omega

/-! ## The main equivalence -/

/-- The easy direction: equal trace distributions force equal orbit counts on
`k`-tuples for **every** `k`, by graded Burnside plus cancellation of `|G| > 0`. -/
theorem card_orbits_eq_of_traceDistribution_eq {G : Type*} [Group G] [Fintype G]
    (X Y : Type*) [MulAction G X] [MulAction G Y] [Finite X] [Finite Y]
    (h : traceDistribution G X = traceDistribution G Y) (k : ℕ) :
    orbitCount G X k = orbitCount G Y k := by
  have hG : 0 < Nat.card G := Nat.card_pos
  have hX := orbitCount_mul_card_group G X k
  have hY := orbitCount_mul_card_group G Y k
  have : orbitCount G X k * Nat.card G = orbitCount G Y k * Nat.card G := by
    rw [hX, hY, h]
  exact Nat.eq_of_mul_eq_mul_right hG this

/-- The hard direction: agreement of the orbit counts on `k`-tuples for the finitely
many `k ≤ max |X| |Y|` already forces the two trace distributions to coincide.

The proof feeds graded Burnside into the interpolation-duality rigidity theorem
`multiset_eq_of_powerSum_eq`. -/
theorem traceDistribution_eq_of_card_orbits_eq {G : Type*} [Group G] [Fintype G]
    (X Y : Type*) [MulAction G X] [MulAction G Y] [Finite X] [Finite Y]
    (h : ∀ k ≤ max (Nat.card X) (Nat.card Y), orbitCount G X k = orbitCount G Y k) :
    traceDistribution G X = traceDistribution G Y := by
  refine multiset_eq_of_powerSum_eq (n := max (Nat.card X) (Nat.card Y) + 1) ?_ ?_ ?_
  · intro a ha
    have := le_card_of_mem_traceDistribution X ha
    have : Nat.card X ≤ max (Nat.card X) (Nat.card Y) := le_max_left _ _
    omega
  · intro b hb
    have := le_card_of_mem_traceDistribution Y hb
    have : Nat.card Y ≤ max (Nat.card X) (Nat.card Y) := le_max_right _ _
    omega
  · intro k hk
    rw [← orbitCount_mul_card_group G X k, ← orbitCount_mul_card_group G Y k,
      h k (Nat.lt_succ_iff.mp hk)]

/-- **Main theorem (Conjecture A).**  Two finite `G`-actions have the same trace
distribution `{|X^g| : g ∈ G}` if and only if they have the same number of orbits on
`k`-tuples for every `k ≤ max |X| |Y|`. -/
theorem traceDistribution_eq_iff_card_orbits_eq {G : Type*} [Group G] [Fintype G]
    (X Y : Type*) [MulAction G X] [MulAction G Y] [Finite X] [Finite Y] :
    traceDistribution G X = traceDistribution G Y
      ↔ ∀ k ≤ max (Nat.card X) (Nat.card Y), orbitCount G X k = orbitCount G Y k :=
  ⟨fun h k _ => card_orbits_eq_of_traceDistribution_eq X Y h k,
   traceDistribution_eq_of_card_orbits_eq X Y⟩

/-- **Rigidity / bootstrapping.**  Agreement of the orbit counts on `k`-tuples for the
finitely many `k ≤ max |X| |Y|` propagates to *all* `k`. -/
theorem card_orbits_eq_of_le {G : Type*} [Group G] [Fintype G]
    (X Y : Type*) [MulAction G X] [MulAction G Y] [Finite X] [Finite Y]
    (h : ∀ k ≤ max (Nat.card X) (Nat.card Y), orbitCount G X k = orbitCount G Y k) :
    ∀ k, orbitCount G X k = orbitCount G Y k :=
  card_orbits_eq_of_traceDistribution_eq X Y (traceDistribution_eq_of_card_orbits_eq X Y h)

/-! ## A bound that does not depend on `|X|`

The joint support of the two trace distributions has at most `2·|G|` distinct values,
simply because each distribution has exactly `|G|` entries.  Feeding this into the
*support* form of power-sum rigidity gives a threshold that is independent of the size
of the sets acted on — a genuine improvement whenever a small group acts on a large
set (e.g. `ℤ/2` acting on a million points: `k < 4` already suffices). -/

theorem card_traceDistribution (G : Type*) [Group G] [Fintype G]
    (X : Type*) [MulAction G X] : Multiset.card (traceDistribution G X) = Nat.card G := by
  rw [traceDistribution]
  simp [Nat.card_eq_fintype_card]

/-- **Group-order bound.**  Agreement of the orbit counts on `k`-tuples for the
`2·|G|` values `k < 2·|G|` already forces the trace distributions to agree — no matter
how large `X` and `Y` are. -/
theorem traceDistribution_eq_of_card_orbits_eq_group_bound {G : Type*} [Group G] [Fintype G]
    (X Y : Type*) [MulAction G X] [MulAction G Y] [Finite X] [Finite Y]
    (h : ∀ k < 2 * Nat.card G, orbitCount G X k = orbitCount G Y k) :
    traceDistribution G X = traceDistribution G Y := by
  classical
  refine multiset_eq_of_powerSum_eq_of_support (n := 2 * Nat.card G) ?_ ?_
  · calc (traceDistribution G X + traceDistribution G Y).toFinset.card
        ≤ Multiset.card (traceDistribution G X + traceDistribution G Y) :=
          Multiset.toFinset_card_le _
      _ = 2 * Nat.card G := by
          rw [Multiset.card_add, card_traceDistribution, card_traceDistribution]
          ring
  · intro k hk
    rw [← orbitCount_mul_card_group G X k, ← orbitCount_mul_card_group G Y k, h k hk]

/-- The group-order bound in `iff` form. -/
theorem traceDistribution_eq_iff_card_orbits_eq_group_bound {G : Type*} [Group G] [Fintype G]
    (X Y : Type*) [MulAction G X] [MulAction G Y] [Finite X] [Finite Y] :
    traceDistribution G X = traceDistribution G Y
      ↔ ∀ k < 2 * Nat.card G, orbitCount G X k = orbitCount G Y k :=
  ⟨fun h k _ => card_orbits_eq_of_traceDistribution_eq X Y h k,
   traceDistribution_eq_of_card_orbits_eq_group_bound X Y⟩

/-- **Combined threshold.**  Only the first
`min (2·|G|) (max |X| |Y| + 1)` orbit counts are ever needed. -/
theorem card_orbits_eq_of_lt_min {G : Type*} [Group G] [Fintype G]
    (X Y : Type*) [MulAction G X] [MulAction G Y] [Finite X] [Finite Y]
    (h : ∀ k < min (2 * Nat.card G) (max (Nat.card X) (Nat.card Y) + 1),
      orbitCount G X k = orbitCount G Y k) :
    ∀ k, orbitCount G X k = orbitCount G Y k := by
  refine card_orbits_eq_of_traceDistribution_eq X Y ?_
  rcases le_total (2 * Nat.card G) (max (Nat.card X) (Nat.card Y) + 1) with hle | hle
  · refine traceDistribution_eq_of_card_orbits_eq_group_bound X Y fun k hk => ?_
    exact h k (by omega)
  · refine traceDistribution_eq_of_card_orbits_eq X Y fun k hk => ?_
    exact h k (by omega)

/-! ## The gradewise q-series form -/

/-- The coefficients of the q-series are exactly the multiplicities of the trace
distribution. -/
theorem coeff_traceSeries (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X]
    (m : ℕ) : (traceSeries G X).coeff m = ((traceDistribution G X).count m : ℤ) := by
  classical
  rw [traceSeries, Polynomial.finset_sum_coeff]
  simp only [Polynomial.coeff_X_pow]
  rw [Finset.sum_boole, traceDistribution, Multiset.count_map]
  norm_cast

/-- The q-series is a *complete* invariant of the trace distribution. -/
theorem traceSeries_eq_iff_traceDistribution_eq {G : Type*} [Group G] [Fintype G]
    (X Y : Type*) [MulAction G X] [MulAction G Y] :
    traceSeries G X = traceSeries G Y ↔ traceDistribution G X = traceDistribution G Y := by
  constructor
  · intro h
    ext m
    have := congrArg (fun p => Polynomial.coeff p m) h
    simp only [coeff_traceSeries] at this
    exact_mod_cast this
  · intro h
    ext m
    rw [coeff_traceSeries, coeff_traceSeries, h]

/-- **Gradewise q-series form of Conjecture A.**  The fixed-point generating
polynomials `∑_{g ∈ G} q^{|X^g|}` of two finite `G`-actions coincide iff the actions
have the same number of orbits on `k`-tuples for all `k ≤ max |X| |Y|` — and then, by
`card_orbits_eq_of_le`, for all `k`. -/
theorem traceDistribution_graded_eq {G : Type*} [Group G] [Fintype G]
    (X Y : Type*) [MulAction G X] [MulAction G Y] [Finite X] [Finite Y] :
    traceSeries G X = traceSeries G Y
      ↔ ∀ k ≤ max (Nat.card X) (Nat.card Y), orbitCount G X k = orbitCount G Y k :=
  (traceSeries_eq_iff_traceDistribution_eq X Y).trans
    (traceDistribution_eq_iff_card_orbits_eq X Y)

end TraceDistribution