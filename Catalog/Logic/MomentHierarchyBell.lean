import Logic.MomentHierarchy

/-!
# The Burnside Moment Hierarchy, part II: symmetric groups, kernels and Bell numbers

This file continues `Logic.MomentHierarchy`. Instantiating the moment identity
`∑_{g ∈ G} |X^g|^k = #((X^k)/G) · |G|` at the full symmetric group `Sym X` turns the
hierarchy into the moment sequence of the number of fixed points of a uniformly random
permutation. The orbits of `Sym X` on `k`-tuples are classified by kernel partitions, so
for `k ≤ |X|` the `k`-th level counts set partitions of a `k`-element set, and the
Cauchy–Schwarz inequality of part I becomes log-convexity of the Bell sequence.
-/

open MulAction Finset

namespace MomentHierarchy

/-! ## Cycle 4: instantiation at the symmetric group

For the natural action of `Equiv.Perm X` on a finite `X` the hierarchy becomes the
moment sequence of the number of fixed points of a uniformly random permutation. The
action is transitive and 2-transitive, so the first two moments are `1` and `2` — the
first two Bell numbers, i.e. the first two moments of a Poisson(1) variable. -/

section Symmetric

variable (X : Type*) [Fintype X] [DecidableEq X]

/-- The natural action of the full symmetric group on ordered pairs of distinct points is
transitive: given `a ≠ b` and `c ≠ d`, the product of two transpositions moves `(a, b)`
to `(c, d)`. -/
theorem perm_pretransitive_offDiag :
    IsPretransitive (Equiv.Perm X) (offDiagSub (Equiv.Perm X) X) := by
  classical
  constructor
  rintro ⟨⟨a, b⟩, hab⟩ ⟨⟨c, d⟩, hcd⟩
  have hab' : a ≠ b := hab
  have hcd' : c ≠ d := hcd
  set t1 : Equiv.Perm X := Equiv.swap a c with ht1
  set b' : X := t1 b with hb'
  have hca : t1 a = c := Equiv.swap_apply_left a c
  have hb'c : b' ≠ c := fun h => hab' (t1.injective (h.trans hca.symm)).symm
  set t2 : Equiv.Perm X := Equiv.swap b' d with ht2
  refine ⟨t2 * t1, ?_⟩
  apply Subtype.ext
  have hc : t2 c = c := Equiv.swap_apply_of_ne_of_ne (Ne.symm hb'c) hcd'
  have hd : t2 b' = d := Equiv.swap_apply_left b' d
  show ((t2 * t1) • ((a, b) : X × X)) = (c, d)
  simp only [Prod.smul_mk, Equiv.Perm.smul_def, Equiv.Perm.mul_apply, hca]
  rw [hc, show t1 b = b' from rfl, hd]

theorem card_perm_eq_factorial : Nat.card (Equiv.Perm X) = Nat.factorial (Nat.card X) := by
  simp [Nat.card_eq_fintype_card, Fintype.card_perm]

/-- **First Poisson moment.** The average number of fixed points of a permutation of a
nonempty finite set is `1`: `∑_{σ} |fix σ| = n!`. -/
theorem sum_fixedPoints_perm [Nonempty X] :
    ∑ σ : Equiv.Perm X, Nat.card (fixedBy X σ) = Nat.factorial (Nat.card X) := by
  have h := (pretransitive_iff_moment_one_eq (G := Equiv.Perm X) (X := X)).1
    Equiv.Perm.instIsPretransitive
  rw [h, card_perm_eq_factorial]

/-- **Second Poisson moment.** For a set with at least two elements the second moment of
the fixed-point statistic is `2`: `∑_{σ} |fix σ|^2 = 2 · n!`. Equivalently, the natural
permutation action of `Sym X` has rank `2`. -/
theorem sum_fixedPoints_perm_sq [Nontrivial X] :
    ∑ σ : Equiv.Perm X, Nat.card (fixedBy X σ) ^ 2 = 2 * Nat.factorial (Nat.card X) := by
  have h := (second_moment_eq_two_iff (G := Equiv.Perm X) (X := X)).1
    ⟨Equiv.Perm.instIsPretransitive, perm_pretransitive_offDiag X⟩
  rw [h, card_perm_eq_factorial]

end Symmetric


/-! ## Cycle 5: kernels, set partitions and log-convexity of the Bell sequence

The hierarchy for the *full* symmetric group is the sharpest instance: two `k`-tuples in
`X` lie in the same `Sym X`-orbit exactly when they have the same **kernel partition**
(`perm_orbit_iff_ker`). Hence, as soon as `k ≤ |X|`, the `k`-th level of the hierarchy
counts set partitions of a `k`-element set:
`#((X^k)/Sym X) = #(Setoid (Fin k))` (`orbits_perm_eq_card_setoid`).

Two consequences follow with no extra work:

* the **Poisson moment theorem** `∑_{σ ∈ Sym X} |fix σ|^k = P(k) · n!` for `k ≤ n`,
  where `P(k)` is the number of set partitions of a `k`-set (the `k`-th Bell number);
* the **log-convexity of the Bell sequence** `P(k+1)^2 ≤ P(k) · P(k+2)`, obtained by
  transporting the Cauchy–Schwarz inequality for fixed-point moments through the
  kernel classification. -/

section Kernels

variable {X : Type*} [Finite X] {k : ℕ}

/-- **Kernel classification of `Sym X`-orbits.** Two `k`-tuples of points of a finite set
lie in the same orbit of the full symmetric group iff they induce the same partition of
the index set `Fin k`. The nontrivial direction extends a bijection between the two
ranges to a permutation of `X`. -/
theorem perm_orbit_iff_ker (f f' : Fin k → X) :
    (∃ σ : Equiv.Perm X, σ • f = f') ↔ Setoid.ker f = Setoid.ker f' := by
  classical
  constructor
  · rintro ⟨σ, rfl⟩
    ext i j
    simp only [Setoid.ker_def]
    constructor
    · intro h; show σ • f i = σ • f j; rw [h]
    · intro h; exact σ.injective h
  · intro hker
    have hiff : ∀ i j, f i = f j ↔ f' i = f' j := fun i j =>
      ⟨fun h => (Setoid.ext_iff.1 hker i j).1 h, fun h => (Setoid.ext_iff.1 hker i j).2 h⟩
    have hmem : ∀ x : Set.range f, ∃ i, f i = x.1 := fun x => x.2
    let F : Set.range f → Set.range f' := fun x => ⟨f' (hmem x).choose, ⟨(hmem x).choose, rfl⟩⟩
    have hF : ∀ (x : Set.range f) (i : Fin k), f i = x.1 → (F x).1 = f' i := by
      intro x i hi
      have h1 : f (hmem x).choose = x.1 := (hmem x).choose_spec
      exact (hiff (hmem x).choose i).1 (h1.trans hi.symm)
    have hinj : Function.Injective F := by
      intro x y hxy
      have h : f' (hmem x).choose = f' (hmem y).choose := congrArg Subtype.val hxy
      have hxy' := (hiff (hmem x).choose (hmem y).choose).2 h
      apply Subtype.ext
      rw [← (hmem x).choose_spec, ← (hmem y).choose_spec, hxy']
    have hsurj : Function.Surjective F := by
      rintro ⟨y, j, rfl⟩
      exact ⟨⟨f j, ⟨j, rfl⟩⟩, Subtype.ext (hF ⟨f j, ⟨j, rfl⟩⟩ j rfl)⟩
    let e : {x // x ∈ Set.range f} ≃ {x // x ∈ Set.range f'} := Equiv.ofBijective F ⟨hinj, hsurj⟩
    refine ⟨e.extendSubtype, ?_⟩
    funext i
    show e.extendSubtype (f i) = f' i
    rw [Equiv.extendSubtype_apply_of_mem e (f i) ⟨i, rfl⟩]
    exact hF ⟨f i, ⟨i, rfl⟩⟩ i rfl

/-- Every partition of `Fin k` is realised as the kernel of a `k`-tuple, provided
`k ≤ |X|`. -/
theorem exists_ker_eq (hk : k ≤ Nat.card X) (r : Setoid (Fin k)) :
    ∃ f : Fin k → X, Setoid.ker f = r := by
  classical
  letI := Fintype.ofFinite X
  have hq : Nat.card (Quotient r) ≤ k := by
    simpa using Nat.card_le_card_of_surjective (Quotient.mk r) Quotient.mk_surjective
  letI := Fintype.ofFinite (Quotient r)
  have hcard : Fintype.card (Quotient r) ≤ Fintype.card X := by
    rw [← Nat.card_eq_fintype_card, ← Nat.card_eq_fintype_card]
    omega
  obtain ⟨emb⟩ := Function.Embedding.nonempty_of_card_le hcard
  refine ⟨fun i => emb (Quotient.mk r i), ?_⟩
  ext i j
  simp only [Setoid.ker_def]
  exact ⟨fun h => Quotient.exact (emb.injective h), fun h => congrArg emb (Quotient.sound h)⟩

/-- **Orbits on `k`-tuples are set partitions.** For `k ≤ |X|` the orbits of the full
symmetric group on `X^k` are in bijection with the partitions of a `k`-element set. -/
theorem orbits_perm_eq_card_setoid (hk : k ≤ Nat.card X) :
    Nat.card (orbitRel.Quotient (Equiv.Perm X) (Fin k → X)) = Nat.card (Setoid (Fin k)) := by
  classical
  have hwd : ∀ f f' : Fin k → X, orbitRel (Equiv.Perm X) (Fin k → X) f f' →
      Setoid.ker f = Setoid.ker f' := by
    intro f f' h
    rw [orbitRel_apply, MulAction.mem_orbit_iff] at h
    obtain ⟨σ, hσ⟩ := h
    exact ((perm_orbit_iff_ker f' f).1 ⟨σ, hσ⟩).symm
  refine Nat.card_congr (Equiv.ofBijective
    (Quotient.lift (fun f : Fin k → X => Setoid.ker f) hwd) ⟨?_, ?_⟩)
  · refine Quotient.ind₂ ?_
    intro f f' h
    exact Quotient.sound (show f ∈ MulAction.orbit (Equiv.Perm X) f' from
      MulAction.mem_orbit_iff.2 ((perm_orbit_iff_ker f' f).2 h.symm))
  · intro r
    obtain ⟨f, hf⟩ := exists_ker_eq (X := X) hk r
    exact ⟨Quotient.mk _ f, hf⟩

end Kernels

section Bell

/-- `partitionCount k` is the number of set partitions of a `k`-element set, i.e. the
`k`-th Bell number, realised as the number of equivalence relations on `Fin k`. -/
noncomputable def partitionCount (k : ℕ) : ℕ := Nat.card (Setoid (Fin k))

/-- The `k`-th level of the symmetric-group hierarchy is the `k`-th Bell number. -/
theorem orbitCount_perm_eq_partitionCount {X : Type*} [Fintype X] [DecidableEq X] {k : ℕ}
    (hk : k ≤ Nat.card X) :
    orbitCount (Equiv.Perm X) X k = partitionCount k :=
  orbits_perm_eq_card_setoid hk

/-- **Poisson moment theorem.** For `k ≤ n = |X|` the `k`-th moment of the fixed-point
statistic of a random permutation is the `k`-th Bell number:
`∑_{σ ∈ Sym X} |fix σ|^k = P(k) · n!`. -/
theorem sum_fixedPoints_perm_pow {X : Type*} [Fintype X] [DecidableEq X] {k : ℕ}
    (hk : k ≤ Nat.card X) :
    ∑ σ : Equiv.Perm X, Nat.card (fixedBy X σ) ^ k
      = partitionCount k * Nat.factorial (Nat.card X) := by
  rw [sum_fixedPoints_pow_eq_orbits_mul_card (G := Equiv.Perm X) (X := X) k,
    show Nat.card (orbitRel.Quotient (Equiv.Perm X) (Fin k → X)) = partitionCount k from
      orbits_perm_eq_card_setoid hk, card_perm_eq_factorial]

/-- **Log-convexity of the Bell numbers.** `P(k+1)^2 ≤ P(k) · P(k+2)`. The proof runs the
Cauchy–Schwarz inequality for the fixed-point moments of `Sym (Fin (k+2))` and transports
it through the kernel classification of orbits. -/
theorem partitionCount_log_convex (k : ℕ) :
    partitionCount (k + 1) ^ 2 ≤ partitionCount k * partitionCount (k + 2) := by
  classical
  have hcard : Nat.card (Fin (k + 2)) = k + 2 := by simp
  have h := orbitCount_log_convex (G := Equiv.Perm (Fin (k + 2))) (X := Fin (k + 2)) k
  have e0 : orbitCount (Equiv.Perm (Fin (k + 2))) (Fin (k + 2)) k = partitionCount k :=
    orbitCount_perm_eq_partitionCount (by omega)
  have e1 : orbitCount (Equiv.Perm (Fin (k + 2))) (Fin (k + 2)) (k + 1)
      = partitionCount (k + 1) := orbitCount_perm_eq_partitionCount (by omega)
  have e2 : orbitCount (Equiv.Perm (Fin (k + 2))) (Fin (k + 2)) (k + 2)
      = partitionCount (k + 2) := orbitCount_perm_eq_partitionCount (by omega)
  rwa [e0, e1, e2] at h

/-- Sanity check at the bottom of the hierarchy: there is exactly one partition of a
`1`-element set. Derived from transitivity of `Sym (Fin 1)` rather than by enumeration. -/
theorem partitionCount_one : partitionCount 1 = 1 := by
  have hcard : Nat.card (Fin 1) = 1 := by simp
  have e1 : orbitCount (Equiv.Perm (Fin 1)) (Fin 1) 1 = partitionCount 1 :=
    orbitCount_perm_eq_partitionCount (by omega)
  have hpos : 0 < Nat.card (Equiv.Perm (Fin 1)) := Nat.card_pos
  have hmom := card_group_mul_orbitCount (G := Equiv.Perm (Fin 1)) (X := Fin 1) 1
  have htr := sum_fixedPoints_perm (Fin 1)
  simp only [pow_one] at hmom
  rw [htr, hcard] at hmom
  simp only [Nat.factorial_one] at hmom
  have : orbitCount (Equiv.Perm (Fin 1)) (Fin 1) 1 * Nat.card (Equiv.Perm (Fin 1))
      = 1 * Nat.card (Equiv.Perm (Fin 1)) := by
    rw [hmom, one_mul, card_perm_eq_factorial, hcard, Nat.factorial_one]
  rw [← e1]
  exact Nat.eq_of_mul_eq_mul_right hpos this

/-- Sanity check: a `2`-element set has exactly two partitions. Derived from the
2-transitivity of the symmetric group via the second-moment criterion. -/
theorem partitionCount_two : partitionCount 2 = 2 := by
  have hcard : Nat.card (Fin 2) = 2 := by simp
  have e2 : orbitCount (Equiv.Perm (Fin 2)) (Fin 2) 2 = partitionCount 2 :=
    orbitCount_perm_eq_partitionCount (by omega)
  have hpos : 0 < Nat.card (Equiv.Perm (Fin 2)) := Nat.card_pos
  have hmom := card_group_mul_orbitCount (G := Equiv.Perm (Fin 2)) (X := Fin 2) 2
  have hsq := sum_fixedPoints_perm_sq (Fin 2)
  rw [hsq, hcard] at hmom
  have hfac : Nat.factorial 2 = 2 := rfl
  rw [hfac] at hmom
  have : orbitCount (Equiv.Perm (Fin 2)) (Fin 2) 2 * Nat.card (Equiv.Perm (Fin 2))
      = 2 * Nat.card (Equiv.Perm (Fin 2)) := by
    rw [hmom, card_perm_eq_factorial, hcard, hfac]
  rw [← e2]
  exact Nat.eq_of_mul_eq_mul_right hpos this


/-- The fixed-point count of a permutation as a decidable `Finset` cardinality; this makes
small instances of the hierarchy machine-computable. -/
theorem card_fixedBy_eq_filter (X : Type*) [Fintype X] [DecidableEq X] (σ : Equiv.Perm X) :
    Nat.card (fixedBy X σ) = (Finset.univ.filter (fun x => σ x = x)).card := by
  rw [Nat.card_eq_fintype_card]
  simp [fixedBy, Fintype.card_subtype]

/-- Machine-checked third moment of `S_3`: `∑_{σ ∈ S_3} |fix σ|^3 = 30`. -/
theorem sum_fixedPoints_perm_three_cube :
    ∑ σ : Equiv.Perm (Fin 3), Nat.card (fixedBy (Fin 3) σ) ^ 3 = 30 := by
  simp only [card_fixedBy_eq_filter]
  decide

/-- `P(3) = 5`: a `3`-element set has five partitions. Obtained by dividing the measured
third moment of `S_3` by `3! = 6` through the Poisson moment theorem. -/
theorem partitionCount_three : partitionCount 3 = 5 := by
  have hcard : Nat.card (Fin 3) = 3 := by simp
  have h := sum_fixedPoints_perm_pow (X := Fin 3) (k := 3) (by rw [hcard])
  rw [sum_fixedPoints_perm_three_cube, hcard] at h
  have hfac : Nat.factorial 3 = 6 := rfl
  rw [hfac] at h
  omega

set_option maxRecDepth 10000 in
/-- Machine-checked fourth moment of `S_4`: `∑_{σ ∈ S_4} |fix σ|^4 = 360`. -/
theorem sum_fixedPoints_perm_four_pow_four :
    ∑ σ : Equiv.Perm (Fin 4), Nat.card (fixedBy (Fin 4) σ) ^ 4 = 360 := by
  simp only [card_fixedBy_eq_filter]
  decide

/-- `P(4) = 15`: a `4`-element set has fifteen partitions, read off from the fourth
moment of `S_4` divided by `4! = 24`. -/
theorem partitionCount_four : partitionCount 4 = 15 := by
  have hcard : Nat.card (Fin 4) = 4 := by simp
  have h := sum_fixedPoints_perm_pow (X := Fin 4) (k := 4) (by rw [hcard])
  rw [sum_fixedPoints_perm_four_pow_four, hcard] at h
  have hfac : Nat.factorial 4 = 24 := rfl
  rw [hfac] at h
  omega

/-- The measured values `P(1), P(2), P(3), P(4) = 1, 2, 5, 15` are consistent with
log-convexity: `P(3)^2 = 25 ≤ 30 = P(2)·P(4)`. -/
theorem partitionCount_log_convex_at_two :
    partitionCount 3 ^ 2 ≤ partitionCount 2 * partitionCount 4 := partitionCount_log_convex 2

end Bell


/-! ## Lab notes: measured data behind the theorems

Exhaustive enumeration (outside Lean) of `S_k := ∑_{g ∈ G} |X^g|^k` and
`o_k := #((X^k)/G)` for several actions; every row satisfies `S_k = o_k · |G|`
(`sum_fixedPoints_pow_eq_orbits_mul_card`) and `o_{k+1}^2 ≤ o_k · o_{k+2}`
(`orbitCount_log_convex`):

| action                 | `|G|` | `o_0 … o_5`            |
|------------------------|-------|------------------------|
| `S_3` on `3` points    | `6`   | `1, 1, 2, 5, 14, 41`   |
| `S_4` on `4` points    | `24`  | `1, 1, 2, 5, 15, 51`   |
| `A_4` on `4` points    | `12`  | `1, 1, 2, 6, 22, 86`   |
| `D_4` on `4` points    | `8`   | `1, 1, 3, 10, 36, 136` |
| `C_4` regular          | `4`   | `1, 1, 4, 16, 64, 256` |
| trivial group, `3` pts | `1`   | `1, 3, 9, 27, 81, 243` |

The symmetric-group rows are Bell numbers truncated to at most `n` blocks
(`o_k = P(k)` exactly while `k ≤ n`, cf. `orbitCount_perm_eq_partitionCount`:
`S_4` gives `51 = 52 - 1` at `k = 5` because partitions into `5` blocks are not
realisable on `4` points). The `C_4` row is `|G|^{k-1}` (`orbitCount_regular_eq`).
The two machine-checked numerical instances below reproduce entries of this table. -/

section LabNotes

/-- Measured entry: the regular action of a group of order `2` on triples has `4` orbits
(`|G|^{k-1} = 2^2`). -/
theorem orbitCount_regular_perm_fin_two :
    orbitCount (Equiv.Perm (Fin 2)) (Equiv.Perm (Fin 2)) 3 = 4 := by
  have hc : Nat.card (Equiv.Perm (Fin 2)) = 2 := by
    rw [card_perm_eq_factorial]
    simp
  rw [orbitCount_regular_eq 3 (by norm_num), hc]
  norm_num

/-- Measured entry: the natural action of `S_2` on pairs has `2` orbits (rank two). -/
theorem orbitCount_perm_fin_two_two : orbitCount (Equiv.Perm (Fin 2)) (Fin 2) 2 = 2 := by
  rw [orbitCount_perm_eq_partitionCount (by simp), partitionCount_two]

end LabNotes

end MomentHierarchy