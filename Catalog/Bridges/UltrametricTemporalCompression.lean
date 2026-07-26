/-
Copyright (c) 2025 Harmonic. All rights reserved.

# Ultrametric Temporal Fixed-Point Compression

A formally verified theory of fixed-point compression in ultrametric proof spaces.
This establishes that iterative contractive dynamics on ultrametric spaces converge
to unique canonical compressed attractors, with quantitative bounds and algorithmic
extractors.

## Main results

* `iterate_dist_bound` — Geometric contraction bound for iterates
* `contractive_adjacent_bound` — Adjacent iterate bound
* `ultrametric_orbit_tail_bound` — Ultrametric telescoping bound
* `fixedPoint_unique` — Uniqueness of fixed points
* `orbit_cauchy` — Cauchy property of orbits
* `fixedPoint_of_complete` — Existence of fixed points in complete spaces
* `exists_unique_fixedPoint` — Existence and uniqueness combined
* `extractor_bound` — Certified extractor with quantitative error bound

## Cross-domain significance

* **Non-Archimedean dynamics**: Ultrametric contraction gives hierarchical ball stabilization
* **Proof compression**: Canonical attractors serve as compressed proof certificates
* **Reversible computation**: Invertible dynamics on compression cores yield periodic quotients
* **Temporal logic**: Convergence to fixed points = denotational semantics of temporal evolution
-/

import Mathlib

open Function Set Filter

namespace UltrametricCompression

/-! ## Part 1: Ultrametric Distance Structure -/

/-- An ultrametric distance on a type `α`, valued in `NNReal`.
Captures the non-Archimedean distance structure fundamental to
p-adic dynamics and hierarchical proof-space geometry. -/
structure UltraDist (α : Type*) where
  /-- The ultrametric distance function -/
  dist : α → α → NNReal
  /-- Distance from a point to itself is zero -/
  dist_self : ∀ x, dist x x = 0
  /-- Symmetry of distance -/
  dist_comm : ∀ x y, dist x y = dist y x
  /-- Separation: zero distance implies equality -/
  dist_eq_zero : ∀ {x y}, dist x y = 0 → x = y
  /-- The strong (ultrametric) triangle inequality -/
  dist_ultra : ∀ x y z, dist x z ≤ max (dist x y) (dist y z)

/-! ## Part 2: Contractive and Nonexpansive Maps -/

/-- A map `F` is contractive on `S` with constant `q < 1`. -/
structure ContractiveOn {α : Type*} (U : UltraDist α) (S : Set α)
    (F : α → α) (q : NNReal) : Prop where
  mapsTo : MapsTo F S S
  q_lt_one : q < 1
  contract : ∀ ⦃x y⦄, x ∈ S → y ∈ S → U.dist (F x) (F y) ≤ q * U.dist x y

/-- A map `F` is nonexpansive on `S`: distances do not increase. -/
structure NonexpansiveOn {α : Type*} (U : UltraDist α) (S : Set α)
    (F : α → α) : Prop where
  mapsTo : MapsTo F S S
  nonexp : ∀ ⦃x y⦄, x ∈ S → y ∈ S → U.dist (F x) (F y) ≤ U.dist x y

/-- Diagonal stability: relative distance ordering is preserved. -/
structure DiagStableOn {α : Type*} (U : UltraDist α) (S : Set α)
    (T : α → α) : Prop where
  mapsTo : MapsTo T S S
  stable : ∀ ⦃x y z⦄, x ∈ S → y ∈ S → z ∈ S →
    U.dist x y ≤ U.dist x z → U.dist (T x) (T y) ≤ U.dist (T x) (T z)

/-- Reversibility: the map has a two-sided inverse on S.
We use `Exists` to wrap the data so this stays in `Prop`. -/
structure ReversibleOn {α : Type*} (S : Set α) (T : α → α) : Prop where
  has_inv : ∃ g : α → α,
    (∀ x ∈ S, g (T x) = x) ∧
    (∀ x ∈ S, T (g x) = x) ∧
    MapsTo T S S

variable {α : Type*}

/-! ## Part 3: Iterate Membership -/

/-
If F maps S to S, then F^[n] x ∈ S for all x ∈ S.
-/
theorem iterate_mem {S : Set α} {F : α → α} (hF : MapsTo F S S) :
    ∀ n x, x ∈ S → F^[n] x ∈ S := by
  exact fun n x hx => hF.iterate n hx

/-! ## Part 4: Iterate Contraction Bounds -/

/-
**Iterated contraction bound**: Under a q-contractive map on S,
n-fold iteration shrinks distances by q^n.
-/
theorem iterate_dist_bound (U : UltraDist α) {S : Set α} {F : α → α} {q : NNReal}
    (hF : ContractiveOn U S F q) (n : ℕ) {x y : α} (hx : x ∈ S) (hy : y ∈ S) :
    U.dist (F^[n] x) (F^[n] y) ≤ q ^ n * U.dist x y := by
  induction' n with n ih;
  · simp +decide;
  · rw [ pow_succ', mul_assoc ];
    exact le_trans ( by simpa only [ Function.iterate_succ_apply' ] using hF.contract ( iterate_mem hF.mapsTo _ _ hx ) ( iterate_mem hF.mapsTo _ _ hy ) ) ( mul_le_mul_left' ih _ )

/-
**Adjacent iterate bound**: The distance between successive iterates
decreases geometrically.
-/
theorem contractive_adjacent_bound (U : UltraDist α) {S : Set α} {F : α → α} {q : NNReal}
    (hF : ContractiveOn U S F q) (n : ℕ) {x : α} (hx : x ∈ S) :
    U.dist (F^[n + 1] x) (F^[n] x) ≤ q ^ n * U.dist (F x) x := by
  convert iterate_dist_bound U hF n ( hF.mapsTo hx ) hx using 1

/-! ## Part 5: Ultrametric Orbit Control -/

/-
**Ultrametric orbit tail bound**: In an ultrametric space, the distance
between any two iterates F^m(x) and F^n(x) (with n ≤ m) is controlled by
q^n · d(F x, x). This uses the ultrametric inequality to replace summation
with maximum, yielding a much tighter bound than in ordinary metric spaces.
-/
theorem ultrametric_orbit_tail_bound (U : UltraDist α) {S : Set α} {F : α → α} {q : NNReal}
    (hF : ContractiveOn U S F q) {m n : ℕ} {x : α} (hx : x ∈ S) (hnm : n ≤ m) :
    U.dist (F^[m] x) (F^[n] x) ≤ q ^ n * U.dist (F x) x := by
  -- By induction on $m - n$, we can show that the distance between $F^m(x)$ and $F^n(x)$ is bounded by $q^n \cdot d(F(x), x)$.
  induction' hnm with m ih;
  · simp +decide [ U.dist_self ];
  · -- By the triangle inequality, we have:
    have h_triangle : U.dist (F^[m+1] x) (F^[n] x) ≤ max (U.dist (F^[m+1] x) (F^[m] x)) (U.dist (F^[m] x) (F^[n] x)) := by
      exact U.dist_ultra _ _ _;
    refine' le_trans h_triangle ( max_le _ _ );
    · exact le_trans ( contractive_adjacent_bound U hF m hx ) ( mul_le_mul_of_nonneg_right ( pow_le_pow_of_le_one ( NNReal.coe_nonneg _ ) ( mod_cast hF.q_lt_one.le ) ih ) ( NNReal.coe_nonneg _ ) );
    · assumption

/-! ## Part 6: Fixed-Point Uniqueness -/

/-
**Uniqueness of fixed points**: If F is q-contractive with q < 1 on S,
then F has at most one fixed point in S.
Proof idea: d(p,p') = d(Fp, Fp') ≤ q · d(p,p'), and q < 1 forces d(p,p') = 0.
-/
theorem fixedPoint_unique (U : UltraDist α) {S : Set α} {F : α → α} {q : NNReal}
    (hF : ContractiveOn U S F q) {p p' : α}
    (hp : p ∈ S) (hp' : p' ∈ S)
    (hFp : F p = p) (hFp' : F p' = p') : p = p' := by
  have h_dist : U.dist p p' ≤ q * U.dist p p' := by
    simpa [ * ] using hF.contract hp hp';
  contrapose! h_dist;
  exact mul_lt_of_lt_one_left ( lt_of_le_of_ne ( NNReal.coe_nonneg _ ) ( Ne.symm ( by intro h; exact h_dist ( U.dist_eq_zero h ) ) ) ) hF.q_lt_one

/-! ## Part 7: Cauchy Orbits -/

/-
**Cauchy orbits**: Under contraction, orbits are Cauchy sequences
in the sense that tail differences become arbitrarily small.
-/
theorem orbit_cauchy (U : UltraDist α) {S : Set α} {F : α → α} {q : NNReal}
    (hF : ContractiveOn U S F q) {x : α} (hx : x ∈ S) :
    ∀ ε : NNReal, 0 < ε →
      ∃ N : ℕ, ∀ m n : ℕ, N ≤ m → N ≤ n →
        U.dist (F^[m] x) (F^[n] x) < ε := by
  intro ε hε;
  obtain ⟨N, hN⟩ : ∃ N : ℕ, q^N * U.dist (F x) x < ε := by
    have := hF.q_lt_one;
    simpa using ( tendsto_pow_atTop_nhds_zero_of_lt_one ( NNReal.coe_nonneg q ) this ) |> fun h => h.mul_const _ |> fun h => h.eventually ( gt_mem_nhds <| by simpa ) |> fun h => h.exists;
  refine' ⟨ N, fun m n hm hn => _ ⟩;
  by_cases hmn : m ≤ n;
  · -- By the properties of the ultrametric distance, we have:
    have h_ultra : U.dist (F^[m] x) (F^[n] x) ≤ q^m * U.dist (F x) x := by
      convert ultrametric_orbit_tail_bound U hF hx hmn using 1;
      exact U.dist_comm _ _;
    exact lt_of_le_of_lt h_ultra ( lt_of_le_of_lt ( mul_le_mul_of_nonneg_right ( pow_le_pow_of_le_one ( NNReal.coe_nonneg _ ) ( le_of_lt hF.q_lt_one ) hm ) ( NNReal.coe_nonneg _ ) ) hN );
  · refine' lt_of_le_of_lt _ hN;
    exact le_trans ( ultrametric_orbit_tail_bound U hF hx ( le_of_not_ge hmn ) ) ( mul_le_mul_of_nonneg_right ( pow_le_pow_of_le_one ( NNReal.coe_nonneg _ ) ( le_of_lt hF.q_lt_one ) hn ) ( NNReal.coe_nonneg _ ) )

/-! ## Part 8: Fixed-Point Existence (with Completeness) -/

/-- Completeness: Cauchy sequences in S converge to a limit in S. -/
structure IsComplete' (U : UltraDist α) (S : Set α) : Prop where
  complete : ∀ (f : ℕ → α), (∀ n, f n ∈ S) →
    (∀ ε : NNReal, 0 < ε → ∃ N, ∀ m n, N ≤ m → N ≤ n → U.dist (f m) (f n) < ε) →
    ∃ p ∈ S, ∀ ε : NNReal, 0 < ε → ∃ N, ∀ n, N ≤ n → U.dist (f n) p < ε

/-
**Fixed-point existence**: In a complete ultrametric space, a contractive
map on a nonempty invariant set has a fixed point, and all orbits converge to it.
-/
theorem fixedPoint_of_complete (U : UltraDist α) {S : Set α} {F : α → α} {q : NNReal}
    (hF : ContractiveOn U S F q) (hS : S.Nonempty)
    (hComplete : IsComplete' U S) :
    ∃ p ∈ S, F p = p ∧
      ∀ x ∈ S, ∀ ε : NNReal, 0 < ε →
        ∃ N, ∀ n, N ≤ n → U.dist (F^[n] x) p < ε := by
  obtain ⟨ p, hp ⟩ := hComplete.complete ( fun n => F^[n] hS.some ) ( fun n => iterate_mem hF.mapsTo _ _ hS.choose_spec ) ( orbit_cauchy U hF hS.choose_spec );
  -- Show that $F(p) = p$.
  have hFp : F p = p := by
    -- By the properties of the ultrametric distance and the contraction property, we have that the distance between F(p) and p is less than or equal to q times the distance between p and F^[N] hS.some.
    have h_dist_Fp_p : ∀ ε > 0, ∃ N, ∀ n ≥ N, U.dist (F p) p ≤ max (q * U.dist p (F^[n] hS.some)) (U.dist (F^[n+1] hS.some) p) := by
      intro ε hε
      obtain ⟨N, hN⟩ : ∃ N, ∀ n ≥ N, U.dist (F p) (F^[n+1] hS.some) ≤ q * U.dist p (F^[n] hS.some) := by
        have := hF.contract;
        exact ⟨ 0, fun n hn => by simpa only [ Function.iterate_succ_apply' ] using this hp.1 ( iterate_mem hF.mapsTo _ _ hS.choose_spec ) ⟩;
      exact ⟨ N, fun n hn => le_trans ( U.dist_ultra _ _ _ ) ( max_le_max ( hN n hn ) le_rfl ) ⟩;
    -- Since $q < 1$, we have that $q * U.dist p (F^[n] hS.some) \to 0$ as $n \to \infty$.
    have h_q_dist_zero : Filter.Tendsto (fun n => q * U.dist p (F^[n] hS.some)) Filter.atTop (nhds 0) := by
      have h_q_dist_zero : Filter.Tendsto (fun n => U.dist p (F^[n] hS.some)) Filter.atTop (nhds 0) := by
        rw [ Metric.tendsto_nhds ];
        simp_all +decide [ dist_comm, U.dist_comm ];
        exact fun ε hε => by rcases hp.2 ⟨ ε, hε.le ⟩ hε with ⟨ N, hN ⟩ ; exact ⟨ N, fun n hn => by simpa [ NNReal.dist_eq ] using hN n hn ⟩ ;
      simpa using h_q_dist_zero.const_mul q;
    -- Since $U.dist (F^[n+1] hS.some) p \to 0$ as $n \to \infty$, we have that $max (q * U.dist p (F^[n] hS.some)) (U.dist (F^[n+1] hS.some) p) \to 0$.
    have h_max_zero : Filter.Tendsto (fun n => max (q * U.dist p (F^[n] hS.some)) (U.dist (F^[n+1] hS.some) p)) Filter.atTop (nhds 0) := by
      have h_dist_zero : Filter.Tendsto (fun n => U.dist (F^[n+1] hS.some) p) Filter.atTop (nhds 0) := by
        exact tendsto_order.2 ⟨ fun ε => by aesop, fun ε hε => by rcases hp.2 ε hε with ⟨ N, hN ⟩ ; exact Filter.eventually_atTop.2 ⟨ N, fun n hn => hN _ ( Nat.le_succ_of_le hn ) ⟩ ⟩;
      simpa using Filter.Tendsto.max h_q_dist_zero h_dist_zero;
    have h_dist_Fp_p_zero : U.dist (F p) p = 0 := by
      exact le_antisymm ( le_of_tendsto_of_tendsto tendsto_const_nhds h_max_zero ( Filter.eventually_atTop.mpr ( h_dist_Fp_p 1 zero_lt_one ) ) ) ( NNReal.coe_nonneg _ );
    grind +suggestions;
  refine' ⟨ p, hp.1, hFp, fun x hx ε hε => _ ⟩;
  -- By the properties of the ultrametric space and the contraction mapping, we have that $U.dist (F^[n] x) p \leq q^n * U.dist x p$.
  have h_dist : ∀ n, U.dist (F^[n] x) p ≤ q^n * U.dist x p := by
    intro n;
    induction' n with n ih;
    · simp +decide;
    · have := hF.contract ( show F^[n] x ∈ S from ?_ ) ( show p ∈ S from hp.1 );
      · simpa only [ hFp, pow_succ', mul_assoc, Function.iterate_succ_apply' ] using this.trans ( mul_le_mul_left' ih _ );
      · exact iterate_mem hF.mapsTo n x hx;
  -- Since $q < 1$, we have that $q^n \to 0$ as $n \to \infty$.
  have h_q_pow_zero : Filter.Tendsto (fun n => q^n * U.dist x p) Filter.atTop (nhds 0) := by
    have h_q_pow_zero : Filter.Tendsto (fun n => q^n) Filter.atTop (nhds 0) := by
      simpa using tendsto_pow_atTop_nhds_zero_of_lt_one ( NNReal.coe_nonneg q ) hF.q_lt_one;
    simpa using h_q_pow_zero.mul tendsto_const_nhds;
  exact Filter.eventually_atTop.mp ( h_q_pow_zero.eventually ( gt_mem_nhds hε ) ) |> fun ⟨ N, hN ⟩ => ⟨ N, fun n hn => lt_of_le_of_lt ( h_dist n ) ( hN n hn ) ⟩

/-
**Existence and uniqueness combined**: The ultrametric Banach fixed-point theorem.
In a nonempty complete invariant region, a contractive map has exactly one fixed point.
-/
theorem exists_unique_fixedPoint (U : UltraDist α) {S : Set α} {F : α → α} {q : NNReal}
    (hF : ContractiveOn U S F q) (hS : S.Nonempty)
    (hComplete : IsComplete' U S) :
    ∃! p, p ∈ S ∧ F p = p ∧
      ∀ x ∈ S, ∀ ε : NNReal, 0 < ε →
        ∃ N, ∀ n, N ≤ n → U.dist (F^[n] x) p < ε := by
  obtain ⟨ p, hp ⟩ := fixedPoint_of_complete U hF hS hComplete;
  refine' ⟨ p, hp, fun q hq => _ ⟩;
  apply fixedPoint_unique;
  all_goals tauto

/-! ## Part 9: Quantitative Convergence to Fixed Point -/

/-
**Quantitative convergence**: Distance from F^n(x) to the fixed point
satisfies d(F^n x, p) ≤ q^n · d(x, p).
-/
theorem iterate_to_fixedPoint_bound (U : UltraDist α) {S : Set α} {F : α → α} {q : NNReal}
    (hF : ContractiveOn U S F q) {p : α} (hp : p ∈ S) (hFp : F p = p)
    (n : ℕ) {x : α} (hx : x ∈ S) :
    U.dist (F^[n] x) p ≤ q ^ n * U.dist x p := by
  convert iterate_dist_bound U hF n hx hp using 1;
  rw [ Function.iterate_fixed hFp ]

/-! ## Part 10: Certified Extractor -/

/-- The extractor: apply F iteratively N times, then compress with C. -/
def extractor (F C : α → α) (N : ℕ) (x : α) : α :=
  C (F^[N] x)

/-
**Extractor error bound with nonexpansive compression**:
The compressed extractor output is within q^N · d(x, p⋆) of the fixed point,
provided C is nonexpansive and fixes p⋆.
-/
theorem extractor_with_compression_bound (U : UltraDist α) {S : Set α}
    {F C : α → α} {q : NNReal}
    (hF : ContractiveOn U S F q)
    (hC : NonexpansiveOn U S C)
    {p : α} (hp : p ∈ S) (hFp : F p = p) (hCp : C p = p)
    (N : ℕ) {x : α} (hx : x ∈ S) :
    U.dist (extractor F C N x) p ≤ q ^ N * U.dist x p := by
  -- By the nonexpansiveness of $C$, we have $U.dist (C (F^[N] x)) (C p) ≤ U.dist (F^[N] x) p$.
  have h_nonexp : U.dist (C (F^[N] x)) (C p) ≤ U.dist (F^[N] x) p := by
    exact hC.nonexp ( iterate_mem hF.mapsTo N x hx ) hp;
  simpa only [ hCp ] using h_nonexp.trans ( UltrametricCompression.iterate_to_fixedPoint_bound U hF hp hFp N hx )

/-! ## Part 11: Compression Core Stability -/

/-- C is idempotent on S. -/
def IdempotentOn (S : Set α) (C : α → α) : Prop :=
  ∀ x ∈ S, C (C x) = C x

/-
**Compression core stability**: If C is idempotent and p⋆ = C(T(p⋆)),
then C(p⋆) = p⋆. The fixed point is in the image of C, i.e., it is
already a compressed representative.
-/
theorem compression_core_stable {S : Set α} {T C : α → α}
    (hC_idem : IdempotentOn S C)
    (_hC_maps : MapsTo C S S)
    (hT_maps : MapsTo T S S)
    {p : α} (hp : p ∈ S) (hFp : C (T p) = p) :
    C p = p := by
  have := hC_idem ( T p ) ( hT_maps hp ) ; aesop;

/-! ## Part 12: Ultrametric Isosceles Lemma -/

/-
**Isosceles lemma**: In an ultrametric space, if d(x,y) < d(y,z),
then d(x,z) = d(y,z). Every ultrametric triangle is isosceles with
the unequal side being the shortest.
-/
theorem ultrametric_isosceles (U : UltraDist α) {x y z : α}
    (h : U.dist x y < U.dist y z) :
    U.dist x z = U.dist y z := by
  apply le_antisymm;
  · exact le_trans ( U.dist_ultra _ _ _ ) ( max_le ( by simpa [ U.dist_comm ] using h.le ) le_rfl );
  · have := U.dist_ultra y x z;
    cases max_cases ( U.dist y x ) ( U.dist x z ) <;> simp_all +decide [ U.dist_comm ];
    · grind;
    · grind

/-! ## Part 13: Ball Stabilization -/

/-- An ultrametric ball centered at c with radius r. -/
def ultraBall (U : UltraDist α) (c : α) (r : NNReal) : Set α :=
  {x | U.dist c x ≤ r}

/-
Under contraction, iterates eventually enter any ball around
the fixed point.
-/
theorem eventually_in_ball (U : UltraDist α) {S : Set α} {F : α → α} {q : NNReal}
    (hF : ContractiveOn U S F q) {p : α} (hp : p ∈ S) (hFp : F p = p)
    {x : α} (hx : x ∈ S) (r : NNReal) (hr : 0 < r) :
    ∃ N, ∀ n, N ≤ n → F^[n] x ∈ ultraBall U p r := by
  obtain ⟨N, hN⟩ : ∃ N : ℕ, q^N * U.dist x p < r := by
    -- Since $q < 1$, we have $q^N \to 0$ as $N \to \infty$.
    have h_q_pow_zero : Filter.Tendsto (fun N : ℕ => q^N * U.dist x p) Filter.atTop (nhds 0) := by
      convert Tendsto.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one ( NNReal.coe_nonneg q ) ( mod_cast hF.q_lt_one ) ) tendsto_const_nhds;
      rw [ ← NNReal.tendsto_coe ];
      congr! 1;
      norm_num;
    exact ( h_q_pow_zero.eventually ( gt_mem_nhds hr ) ) |> fun h => h.exists;
  refine' ⟨ N, fun n hn => _ ⟩;
  refine' le_trans _ hN.le;
  convert iterate_to_fixedPoint_bound U hF hp hFp n hx |> le_trans <| mul_le_mul_right' ( pow_le_pow_of_le_one ( show ( 0 : NNReal ) ≤ q by exact NNReal.coe_nonneg _ ) ( show ( q : NNReal ) ≤ 1 by exact le_of_lt hF.q_lt_one ) hn ) _ using 1;
  exact U.dist_comm _ _

/-! ## Part 14: Composition Theorems -/

/-- If C ∘ T is contractive, we can directly apply the fixed-point theory. -/
theorem composed_fixedPoint_char {T C : α → α} {p : α}
    (hFp : (C ∘ T) p = p) : C (T p) = p := hFp

/-- **Full temporal compression theorem**: Combining all results,
for C ∘ T contractive on a complete nonempty invariant set,
there exists a unique compressed fixed point that all orbits converge to. -/
theorem temporal_compression_theorem (U : UltraDist α) {S : Set α}
    {T C : α → α} {q : NNReal}
    (hCT : ContractiveOn U S (C ∘ T) q) (hS : S.Nonempty)
    (hComplete : IsComplete' U S) :
    ∃! p, p ∈ S ∧ C (T p) = p ∧
      ∀ x ∈ S, ∀ ε : NNReal, 0 < ε →
        ∃ N, ∀ n, N ≤ n → U.dist ((C ∘ T)^[n] x) p < ε :=
  exists_unique_fixedPoint U hCT hS hComplete

end UltrametricCompression