/-
# Discrete Morse Inequalities: From Geometry to Topology

This file formalizes the algebraic heart of discrete Morse theory in a finite
combinatorial setting. We prove that homological complexity (Betti numbers)
is bounded by geometric complexity (critical cell counts), and that the
Euler characteristic is computed by the alternating sum of critical cells.

## Main Results

* `homology_finrank_le` — For any finite chain complex of finite-dimensional
  vector spaces, the dimension of homology in each degree is bounded by
  the dimension of the chain group: `dim H_n ≤ dim C_n`.

* `euler_char_eq` — The Euler characteristic identity: the alternating sum
  of chain group dimensions equals the alternating sum of homology dimensions,
  for complexes that vanish above a given degree.

* `weak_morse_inequality` — For any discrete Morse reduction, the Betti number
  in each degree is bounded by the number of critical cells.

* `euler_char_morse` — The alternating sum of Betti numbers equals the
  alternating sum of critical cell counts.

* `strong_morse_inequality` — The cumulative Morse inequalities.
-/

import Mathlib

open Module LinearMap Submodule

/-! ## Finite Chain Complexes -/

/-- A finite chain complex of finite-dimensional vector spaces over a field K.
The differential `d n` maps from degree `n+1` to degree `n`, satisfying `d ∘ d = 0`. -/
structure FinChainComplex (K : Type*) [Field K] where
  /-- The chain module in each degree -/
  C : ℕ → Type*
  /-- Each chain module is an additive commutative group -/
  instAddCommGroup : ∀ n, AddCommGroup (C n)
  /-- Each chain module is a K-module -/
  instModule : ∀ n, Module K (C n)
  /-- Each chain module is finite-dimensional over K -/
  instFiniteDimensional : ∀ n, FiniteDimensional K (C n)
  /-- The boundary operator from degree n+1 to degree n -/
  d : ∀ n, C (n + 1) →ₗ[K] C n
  /-- The chain complex condition: d ∘ d = 0 -/
  d_comp_d : ∀ n, (d n).comp (d (n + 1)) = 0

attribute [instance] FinChainComplex.instAddCommGroup
  FinChainComplex.instModule FinChainComplex.instFiniteDimensional

namespace FinChainComplex

variable {K : Type*} [Field K] (F : FinChainComplex K)

/-- Boundaries at degree n: the image of the differential from degree n+1. -/
noncomputable def boundaries (n : ℕ) : Submodule K (F.C n) :=
  range (F.d n)

/-- Cycles at degree n: the kernel of the outgoing differential.
At degree 0, everything is a cycle (there is no lower degree).
At degree n+1, cycles are ker(d_n). -/
noncomputable def cycles : ∀ n, Submodule K (F.C n)
  | 0 => ⊤
  | n + 1 => ker (F.d n)

/-- The chain complex condition implies boundaries ≤ cycles. -/
theorem boundaries_le_cycles (n : ℕ) : F.boundaries n ≤ F.cycles n := by
  cases n with
  | zero => exact le_top
  | succ n =>
    intro x hx
    simp only [boundaries, cycles, mem_ker] at *
    obtain ⟨y, rfl⟩ := hx
    have := LinearMap.ext_iff.mp (F.d_comp_d n) y
    simp [comp_apply] at this
    exact this

/-- Boundaries as a submodule of cycles (via comap of the inclusion). -/
noncomputable def boundariesInCycles (n : ℕ) : Submodule K (F.cycles n) :=
  (F.boundaries n).comap (F.cycles n).subtype

/-- Homology at degree n: cycles modulo boundaries. -/
noncomputable def homology (n : ℕ) := (F.cycles n) ⧸ (F.boundariesInCycles n)

noncomputable instance homologyAddCommGroup (n : ℕ) : AddCommGroup (F.homology n) :=
  inferInstanceAs (AddCommGroup ((F.cycles n) ⧸ (F.boundariesInCycles n)))

noncomputable instance homologyModule (n : ℕ) : Module K (F.homology n) :=
  inferInstanceAs (Module K ((F.cycles n) ⧸ (F.boundariesInCycles n)))

noncomputable instance homologyFiniteDimensional (n : ℕ) :
    FiniteDimensional K (F.homology n) :=
  inferInstanceAs (FiniteDimensional K ((F.cycles n) ⧸ (F.boundariesInCycles n)))

/-- The rank of homology in degree n (the n-th Betti number). -/
noncomputable def homologyFinrank (n : ℕ) : ℕ :=
  finrank K (F.homology n)

/-! ## Theorem A': Algebraic Weak Inequality -/

/-- **Algebraic weak inequality**: `dim H_n ≤ dim C_n`.
Homology is a quotient of a subspace (cycles) of the chain group,
hence has dimension at most that of the chain group. -/
theorem homology_finrank_le (n : ℕ) :
    F.homologyFinrank n ≤ finrank K (F.C n) := by
  unfold homologyFinrank homology
  calc finrank K ((F.cycles n) ⧸ (F.boundariesInCycles n))
      ≤ finrank K (F.cycles n) := Submodule.finrank_quotient_le _
    _ ≤ finrank K (F.C n) := Submodule.finrank_le _

/-! ## Euler Characteristic Identity

We prove: for a chain complex with `range(d_N) = 0`,
  `∑_{n=0}^{N} (-1)^n dim C_n = ∑_{n=0}^{N} (-1)^n dim H_n`.

The proof uses the rank-nullity telescope. -/

/-- Finrank of cycles at degree 0 equals finrank of C 0. -/
theorem finrank_cycles_zero :
    finrank K (F.cycles 0) = finrank K (F.C 0) := by
  simp [cycles, finrank_top]

/-- Finrank of cycles at degree n+1 equals finrank of ker(d n). -/
theorem finrank_cycles_succ (n : ℕ) :
    finrank K (F.cycles (n + 1)) = finrank K (ker (F.d n)) := by
  rfl

/-- Rank-nullity: dim C_{n+1} = dim ker(d_n) + dim range(d_n). -/
theorem rank_nullity (n : ℕ) :
    finrank K (F.C (n + 1)) =
    finrank K (ker (F.d n)) + finrank K (range (F.d n)) := by
  have := LinearMap.finrank_range_add_finrank_ker (F.d n)
  omega

/-- The quotient formula: dim(cycles_n) = dim(H_n) + dim(boundaries_in_cycles_n). -/
theorem homology_rank_decomp (n : ℕ) :
    finrank K (F.cycles n) =
    F.homologyFinrank n + finrank K (F.boundariesInCycles n) := by
  unfold homologyFinrank homology
  have := Submodule.finrank_quotient_add_finrank (F.boundariesInCycles n)
  omega

/-
The finrank of boundariesInCycles equals the finrank of boundaries,
when boundaries ≤ cycles.
-/
theorem finrank_boundariesInCycles (n : ℕ) :
    finrank K (F.boundariesInCycles n) = finrank K (F.boundaries n) := by
  refine' LinearEquiv.finrank_eq _;
  refine' ( LinearEquiv.ofBijective _ ⟨ _, _ ⟩ );
  refine' { toFun := fun x => ⟨ x.val, x.property ⟩, map_add' := _, map_smul' := _ };
  all_goals norm_num [ Function.Injective, Function.Surjective ];
  · aesop;
  · aesop;
  · exact fun a ha => ⟨ F.boundaries_le_cycles n ha, ha ⟩

/-
**Euler characteristic identity**: For a chain complex where `range(d_N) = 0`,
  `∑_{n=0}^{N} (-1)^n dim C_n = ∑_{n=0}^{N} (-1)^n dim H_n`
-/
theorem euler_char_eq (N : ℕ)
    (hN : finrank K (range (F.d N)) = 0) :
    (∑ n ∈ Finset.range (N + 1), (-1 : ℤ) ^ n * (finrank K (F.C n) : ℤ)) =
    (∑ n ∈ Finset.range (N + 1), (-1 : ℤ) ^ n * (F.homologyFinrank n : ℤ)) := by
  -- We apply the auxiliary lemma by induction on `N`.
  -- The hypothesis of this lemma is that `range(d_N)` has some finrank `r`.
  suffices h_aux : ∀ (N : ℕ) (r : ℕ), finrank K (range (F.d N)) = r →
      (∑ n ∈ Finset.range (N + 1), (-1 : ℤ) ^ n * ↑(finrank K (F.C n))) -
      (∑ n ∈ Finset.range (N + 1), (-1 : ℤ) ^ n * ↑(F.homologyFinrank n)) =
      (-1 : ℤ) ^ N * ↑r by
        grind +splitImp;
  intro N r hr
  induction' N with N ih generalizing r;
  · have := F.homology_rank_decomp 0;
    have := F.finrank_cycles_zero; have := F.finrank_boundariesInCycles 0; simp_all +decide ;
    exact hr ▸ rfl;
  · simp_all +decide [ Finset.sum_range_succ, pow_succ' ];
    have := F.rank_nullity N; have := F.homology_rank_decomp ( N + 1 ) ; have := F.finrank_boundariesInCycles ( N + 1 ) ; simp_all +decide [ Finset.sum_range_succ, pow_succ' ] ;
    have := F.finrank_cycles_succ N; simp_all +decide [ Finset.sum_range_succ, pow_succ' ] ;
    lia

/-! ## Strong Algebraic Inequality (without vanishing hypothesis)

The difference `∑ (-1)^n dim C_n - ∑ (-1)^n dim H_n` equals
`(-1)^N * finrank(range(d_N))`, which when multiplied by `(-1)^N`
gives the non-negative quantity `finrank(range(d_N))`. This yields
the strong algebraic inequality without any vanishing hypothesis. -/

/-
Auxiliary identity: the difference of alternating sums equals
`(-1)^N * finrank(range d_N)`. This is the key telescoping identity
from which both the Euler characteristic and strong inequalities follow.
-/
theorem euler_char_diff (N : ℕ) :
    (∑ n ∈ Finset.range (N + 1), (-1 : ℤ) ^ n * (finrank K (F.C n) : ℤ)) -
    (∑ n ∈ Finset.range (N + 1), (-1 : ℤ) ^ n * (F.homologyFinrank n : ℤ)) =
    (-1 : ℤ) ^ N * (finrank K (range (F.d N)) : ℤ) := by
  induction' N with N ih;
  · -- By definition of homology, we have:
    have h_homology : F.homologyFinrank 0 = finrank K (F.C 0) - finrank K (F.boundaries 0) := by
      have h_homology : F.homologyFinrank 0 = finrank K (F.cycles 0) - finrank K (F.boundariesInCycles 0) := by
        rw [ ← Submodule.finrank_quotient_add_finrank ( F.boundariesInCycles 0 ) ];
        aesop;
      rw [ h_homology, finrank_cycles_zero, finrank_boundariesInCycles ];
    simp_all +decide [ FinChainComplex.boundaries ];
    rw [ Nat.cast_sub ];
    · ring;
    · exact Submodule.finrank_le _;
  · have := F.rank_nullity ( N + 1 ) ; ( have := F.homology_rank_decomp ( N + 1 ) ; ( have := F.finrank_boundariesInCycles ( N + 1 ) ; ( have := F.finrank_cycles_succ ( N ) ; simp_all +decide [ pow_succ, Finset.sum_range_succ ] ; ) ) );
    have := F.rank_nullity N; ( have := F.homology_rank_decomp N; ( have := F.finrank_boundariesInCycles N; simp_all +decide [ pow_succ', Finset.sum_range_succ ] ; ) );
    grind

/-
**Strong algebraic inequality**: For each k, the cumulative alternating
partial sums of chain dimensions dominate those of homology dimensions.

  `∑_{i=0}^{k} (-1)^{k-i} dim H_i ≤ ∑_{i=0}^{k} (-1)^{k-i} dim C_i`

No vanishing hypothesis is needed. The difference equals `finrank(range d_k) ≥ 0`.
-/
theorem strong_algebraic_inequality (k : ℕ) :
    (∑ i ∈ Finset.range (k + 1), (-1 : ℤ) ^ (k - i) * (F.homologyFinrank i : ℤ)) ≤
    (∑ i ∈ Finset.range (k + 1), (-1 : ℤ) ^ (k - i) * (finrank K (F.C i) : ℤ)) := by
  -- By multiplying both sides of the equation from `euler_char_diff` by $(-1)^k$, we obtain the desired inequality.
  have h_mul : (-1 : ℤ) ^ k * (∑ i ∈ Finset.range (k + 1), (-1 : ℤ) ^ i * (finrank K (F.C i) : ℤ)) - (-1 : ℤ) ^ k * (∑ i ∈ Finset.range (k + 1), (-1 : ℤ) ^ i * (F.homologyFinrank i : ℤ)) = finrank K (range (F.d k)) := by
    convert congr_arg ( fun x : ℤ => ( -1 : ℤ ) ^ k * x ) ( euler_char_diff F k ) using 1 ; ring;
    by_cases h : Even k <;> simp_all +decide;
  -- By multiplying both sides of the equation from `euler_char_diff` by $(-1)^k$, we obtain the desired inequality. Notice that $(-1)^k * (-1)^i = (-1)^{k-i}$.
  have h_mul' : ∑ i ∈ Finset.range (k + 1), (-1 : ℤ) ^ (k - i) * (finrank K (F.C i) : ℤ) - ∑ i ∈ Finset.range (k + 1), (-1 : ℤ) ^ (k - i) * (F.homologyFinrank i : ℤ) = finrank K (range (F.d k)) := by
    convert h_mul using 1;
    norm_num [ Finset.mul_sum _ _ _, mul_assoc, ← pow_add ];
    refine' congrArg₂ _ ( Finset.sum_congr rfl fun i hi => _ ) ( Finset.sum_congr rfl fun i hi => _ ) <;> rw [ ← Nat.sub_add_cancel ( Finset.mem_range_succ_iff.mp hi ), pow_add ] <;> ring;
    · norm_num [ pow_mul' ];
    · norm_num [ pow_mul' ];
  linarith [ show 0 ≤ finrank K ( LinearMap.range ( F.d k ) ) by positivity ]

end FinChainComplex

/-! ## Discrete Morse Data -/

/-- Abstract discrete Morse data: an original complex equipped with
a homology-equivalent reduced complex whose dimensions give critical counts. -/
structure DiscreteMorseData (K : Type*) [Field K] where
  /-- The original chain complex -/
  original : FinChainComplex K
  /-- The number of critical cells in each degree -/
  criticalCount : ℕ → ℕ
  /-- The reduced Morse complex -/
  reduced : FinChainComplex K
  /-- The reduced complex has dimension = critical count in each degree -/
  reduced_finrank : ∀ n,
    finrank K (reduced.C n) = criticalCount n
  /-- Homology is preserved: the original and reduced complexes
    have isomorphic homology in each degree -/
  homology_equiv : ∀ n,
    reduced.homology n ≃ₗ[K] original.homology n

namespace DiscreteMorseData

variable {K : Type*} [Field K] (M : DiscreteMorseData K)

/-- The n-th Betti number of the original complex. -/
noncomputable def betti (n : ℕ) : ℕ := M.original.homologyFinrank n

/-
Betti number equals the homology finrank of the reduced complex,
since homology is preserved by the linear equivalence.
-/
theorem betti_eq_reduced_homology (n : ℕ) :
    M.betti n = M.reduced.homologyFinrank n := by
  exact LinearEquiv.finrank_eq ( M.homology_equiv n ).symm

/-! ## Weak Morse Inequality -/

/-- **Weak Morse Inequality**: `β_n ≤ crit_n`.

This follows from the algebraic inequality applied to the reduced complex,
combined with the fact that reduced complex dimensions equal critical counts. -/
theorem weak_morse_inequality (n : ℕ) :
    M.betti n ≤ M.criticalCount n := by
  rw [M.betti_eq_reduced_homology]
  calc M.reduced.homologyFinrank n
      ≤ finrank K (M.reduced.C n) := M.reduced.homology_finrank_le n
    _ = M.criticalCount n := M.reduced_finrank n

/-! ## Euler Characteristic Morse Identity -/

/-
**Euler characteristic Morse identity**:
  `∑_{n=0}^{N} (-1)^n β_n = ∑_{n=0}^{N} (-1)^n crit_n`
-/
theorem euler_char_morse (N : ℕ)
    (hN : finrank K (range (M.reduced.d N)) = 0) :
    (∑ n ∈ Finset.range (N + 1), (-1 : ℤ) ^ n * (M.betti n : ℤ)) =
    (∑ n ∈ Finset.range (N + 1), (-1 : ℤ) ^ n * (M.criticalCount n : ℤ)) := by
  -- Replace M.betti n with M.reduced.homologyFinrank n using betti_eq_reduced_homology
  have h1 : (∑ n ∈ Finset.range (N + 1), (-1 : ℤ) ^ n * (M.betti n : ℤ)) = (∑ n ∈ Finset.range (N + 1), (-1 : ℤ) ^ n * (M.reduced.homologyFinrank n : ℤ)) := by
    exact Finset.sum_congr rfl fun _ _ => by rw [ M.betti_eq_reduced_homology ] ;
  -- Apply M.reduced.euler_char_eq N hN to get ∑ (-1)^n finrank(reduced.C n) = ∑ (-1)^n reduced.homologyFinrank n
  have h2 : (∑ n ∈ Finset.range (N + 1), (-1 : ℤ) ^ n * (finrank K (M.reduced.C n) : ℤ)) = (∑ n ∈ Finset.range (N + 1), (-1 : ℤ) ^ n * (M.reduced.homologyFinrank n : ℤ)) := by
    convert M.reduced.euler_char_eq N hN using 1;
  exact h1.trans ( h2.symm.trans ( Finset.sum_congr rfl fun _ _ => by rw [ M.reduced_finrank ] ) )

/-! ## Strong Morse Inequalities -/

/-
**Strong Morse inequality** (without vanishing hypothesis): For each k,
  `∑_{i=0}^{k} (-1)^{k-i} β_i ≤ ∑_{i=0}^{k} (-1)^{k-i} crit_i`

This is the genuine strong Morse inequality. The difference equals
`finrank(range(d_k^{red})) ≥ 0`.
-/
theorem strong_morse_inequality (k : ℕ) :
    (∑ i ∈ Finset.range (k + 1), (-1 : ℤ) ^ (k - i) * (M.betti i : ℤ)) ≤
    (∑ i ∈ Finset.range (k + 1), (-1 : ℤ) ^ (k - i) * (M.criticalCount i : ℤ)) := by
  convert M.reduced.strong_algebraic_inequality k using 1 <;> simp +decide [ mul_comm, M.betti_eq_reduced_homology, M.reduced_finrank ]

end DiscreteMorseData

/-! ## Concrete Example: The Point -/

/-- The chain complex of a point: K in degree 0, trivial elsewhere. -/
noncomputable def pointComplex (K : Type*) [Field K] : FinChainComplex K where
  C := fun n => match n with
    | 0 => K
    | _ + 1 => Fin 0 → K
  instAddCommGroup := fun n => by cases n <;> infer_instance
  instModule := fun n => by cases n <;> infer_instance
  instFiniteDimensional := fun n => by cases n <;> infer_instance
  d := fun n => 0
  d_comp_d := fun n => by simp

/-- The point has dim C_0 = 1. -/
theorem pointComplex_finrank_zero (K : Type*) [Field K] :
    finrank K ((pointComplex K).C 0) = 1 := by
  simp [pointComplex, finrank_self]

/-- The point has dim C_{n+1} = 0. -/
theorem pointComplex_finrank_succ (K : Type*) [Field K] (n : ℕ) :
    finrank K ((pointComplex K).C (n + 1)) = 0 := by
  simp [pointComplex]

/-- Morse data for a point: one critical 0-cell, no others. -/
noncomputable def pointMorseData (K : Type*) [Field K] : DiscreteMorseData K where
  original := pointComplex K
  criticalCount := fun n => match n with
    | 0 => 1
    | _ + 1 => 0
  reduced := pointComplex K
  reduced_finrank := fun n => by
    cases n with
    | zero => exact pointComplex_finrank_zero K
    | succ n => exact pointComplex_finrank_succ K n
  homology_equiv := fun n => LinearEquiv.refl K _

/-- The point has β_0 ≤ 1. -/
theorem point_weak_morse (K : Type*) [Field K] :
    (pointMorseData K).betti 0 ≤ (pointMorseData K).criticalCount 0 :=
  (pointMorseData K).weak_morse_inequality 0