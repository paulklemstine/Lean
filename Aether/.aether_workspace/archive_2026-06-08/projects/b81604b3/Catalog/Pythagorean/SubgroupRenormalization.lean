/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Renormalization Group for Subgroup Ensembles

This file introduces the first formal framework for renormalization group (RG)
dynamics on finite-group subgroup ensembles. We define weighted subgroup
ensembles, partition functions, pressure functionals, coarse-graining
operators, RG fixed points, and universality classes, then prove exact
scaling laws, fixed-point theorems, and critical exponent identities.

## Main Definitions

* `SubgroupEnsemble` — A weighted finite family of subgroups.
* `ensemblePartition` — Partition function of an ensemble at inverse temperature β.
* `ensemblePressure` — Log-partition function (pressure / free energy).
* `CoarseGraining` — An operator on ensembles with a pressure scaling law.
* `IsRGFixedPoint` — Predicate for fixed points of a coarse-graining map.
* `SameUniversalityClass` — Equivalence relation: identical pressure under
  all RG iterates.

## Main Results

* `pressure_iterate_of_coarseGraining` — Pressure transforms geometrically
  under iterated coarse-graining: P(R^n(E)) = s^n * P(E).
* `pressure_invariant_at_fixedPoint` — At a fixed point with scale factor 1,
  pressure is exactly invariant under all iterates.
* `criticalExponent_from_scaling` — The critical exponent identity
  a = log l / log m linking pressure eigenvalue to parameter eigenvalue.
* `intensivePressure_convergence` — The intensive pressure F_n/n converges
  to F_1 for product ensembles (thermodynamic limit).
* `scalar_linearization_iter` — Iterated linear maps give power growth,
  bridging to spectral/dynamical systems theory.

## Application Keywords

renormalization group, subgroup growth, pressure, universality classes,
coarse-graining, critical exponents, dynamical systems, algebraic
statistical mechanics, finite groups, thermodynamic limit.
-/

import Mathlib

open Real Finset Filter

/-! ## Core Definitions -/

/-- A **subgroup ensemble** over a group `G` is a finite weighted family
of subgroups. The weight function assigns a nonnegative real to each
subgroup in the carrier set, representing its statistical significance. -/
structure SubgroupEnsemble (G : Type*) [Group G] where
  /-- The finite set of subgroups in the ensemble -/
  carriers : Finset (Subgroup G)
  /-- Weight function on subgroups -/
  weight : Subgroup G → ℝ
  /-- Weights are nonnegative on carriers -/
  weight_nonneg : ∀ H ∈ carriers, 0 ≤ weight H

/-- A complexity measure on subgroups. In practice this could be
log-index, generator count, or codimension. We abstract it as
any real-valued function on subgroups. -/
def SubgroupComplexity (G : Type*) [Group G] := Subgroup G → ℝ

/-- The **partition function** of a subgroup ensemble at inverse
temperature `b` with complexity measure `c`:
  Z(b) = sum_{H in carriers} exp(-b * c(H)) * w(H) -/
noncomputable def ensemblePartition
    {G : Type*} [Group G]
    (b : ℝ) (c : SubgroupComplexity G) (E : SubgroupEnsemble G) : ℝ :=
  ∑ H ∈ E.carriers, Real.exp (-b * c H) * E.weight H

/-- The **ensemble pressure** (log-partition function / free energy):
  P(b) = log Z(b) -/
noncomputable def ensemblePressure
    {G : Type*} [Group G]
    (b : ℝ) (c : SubgroupComplexity G) (E : SubgroupEnsemble G) : ℝ :=
  Real.log (ensemblePartition b c E)

/-! ## Coarse-Graining and RG Structure -/

/-- A **coarse-graining operator** on subgroup ensembles consists of:
- A map on ensembles (the RG transformation)
- A pressure scaling function s(b)
- A proof that the map transforms pressure by the scaling factor

This is the central algebraic analogue of the Wilsonian RG. -/
structure CoarseGraining (G : Type*) [Group G] where
  /-- The coarse-graining map on ensembles -/
  map : SubgroupEnsemble G → SubgroupEnsemble G
  /-- The pressure scaling factor at each b -/
  pressureScale : ℝ → ℝ
  /-- The complexity measure used -/
  complexity : SubgroupComplexity G
  /-- Fundamental RG equation: pressure transforms by scaling -/
  pressure_map : ∀ (b : ℝ) (E : SubgroupEnsemble G),
    ensemblePressure b complexity (map E) =
    pressureScale b * ensemblePressure b complexity E

/-- An ensemble `E` is an **RG fixed point** of coarse-graining `R`
if the map leaves it invariant. -/
def IsRGFixedPoint {G : Type*} [Group G]
    (R : CoarseGraining G) (E : SubgroupEnsemble G) : Prop :=
  R.map E = E

/-- A **universality class** under an RG flow: two ensembles are in
the same class if they have identical pressure under all iterates. -/
def SameUniversalityClass {G : Type*} [Group G]
    (R : CoarseGraining G) (E1 E2 : SubgroupEnsemble G) : Prop :=
  ∀ (b : ℝ) (n : ℕ),
    ensemblePressure b R.complexity ((R.map^[n]) E1) =
    ensemblePressure b R.complexity ((R.map^[n]) E2)

/-! ## Theorem 1: Geometric pressure scaling under iterated coarse-graining

The fundamental RG law: pressure transforms geometrically under
iterated application of the coarse-graining map.
  P(R^n(E), b) = s(b)^n * P(E, b)

This is the algebraic analogue of the transfer-operator eigenvalue
equation in statistical mechanics. -/

theorem pressure_iterate_of_coarseGraining
    {G : Type*} [Group G]
    (R : CoarseGraining G) (E : SubgroupEnsemble G) (b : ℝ) :
    ∀ n : ℕ,
      ensemblePressure b R.complexity ((R.map^[n]) E) =
      (R.pressureScale b) ^ n * ensemblePressure b R.complexity E := by
  intro n; induction n <;> simp_all +decide [ Function.iterate_succ_apply', pow_succ', mul_assoc ] ; ring;
  rw [ mul_assoc, ← ‹ensemblePressure b R.complexity ( R.map^[ _ ] E ) = R.pressureScale b ^ _ * ensemblePressure b R.complexity E›, R.pressure_map ]

/-! ## Theorem 2: Pressure invariance at fixed points -/

/-
At a fixed point, all iterates return the same ensemble.
-/
theorem fixedPoint_iterate_eq
    {G : Type*} [Group G]
    (R : CoarseGraining G) (E : SubgroupEnsemble G)
    (hfix : IsRGFixedPoint R E) :
    ∀ n : ℕ, (R.map^[n]) E = E := by
  exact fun n => Function.iterate_fixed hfix n

/-
At a fixed point with unit scaling factor, pressure is exactly
invariant under all iterates.
-/
theorem pressure_invariant_at_fixedPoint
    {G : Type*} [Group G]
    (R : CoarseGraining G) (E : SubgroupEnsemble G) (b : ℝ)
    (hfix : IsRGFixedPoint R E)
    (_hscale : R.pressureScale b = 1) :
    ∀ n : ℕ,
      ensemblePressure b R.complexity ((R.map^[n]) E) =
      ensemblePressure b R.complexity E := by
  intro n
  rw [fixedPoint_iterate_eq R E hfix n]

/-! ## Theorem 3: Critical exponent from linearized scaling -/

/-
The exact identity linking scaling eigenvalues to critical exponents:
if l = m^a with l > 0 and m > 1, then a = log l / log m.
-/
theorem criticalExponent_from_scaling
    (l m a : ℝ) (_hl : 0 < l) (hm : 1 < m) (ha : l = m ^ a) :
    a = Real.log l / Real.log m := by
  rw [ ha, Real.log_rpow ( by linarith ), mul_div_cancel_right₀ _ ( ne_of_gt ( Real.log_pos hm ) ) ]

/-
Parameterized version: if Pi(m*t) = l*Pi(t) and Pi(t) = t^a,
then a = log l / log m.
-/
theorem pressure_scaling_exponent_formula
    (Pi_fn : ℝ → ℝ) (l m a : ℝ)
    (_hl : 0 < l) (hm : 1 < m) (_ha : 0 < a)
    (hscale : ∀ t, 0 < t → Pi_fn (m * t) = l * Pi_fn t)
    (hmodel : ∀ t, 0 < t → Pi_fn t = t ^ a) :
    a = Real.log l / Real.log m := by
  -- From the scaling relation, we have $m^a = l$.
  have hma : m ^ a = l := by
    have := hscale 1 one_pos; have := hscale m ( by positivity ) ; simp_all +decide ;
    rw [ ← hmodel m ( by positivity ), ‹Pi_fn m = l› ];
  exact hma ▸ by rw [ Real.log_rpow ( by positivity ),
    mul_div_cancel_right₀ _ ( ne_of_gt ( Real.log_pos hm ) ) ] ;

/-! ## Theorem 4: Extensivity and thermodynamic limit -/

/-- Product extensivity: F(n) = n * F(1) from the recursion
F(0) = 0, F(n+1) = F(n) + F(1). -/
theorem ensemblePressure_product_extensivity
    (F : ℕ → ℝ) (hzero : F 0 = 0)
    (hstep : ∀ n, F (n + 1) = F n + F 1) :
    ∀ n, F n = (n : ℝ) * F 1 := by
  intro n
  induction n with
  | zero => simp [hzero]
  | succ n ih => rw [hstep, ih]; push_cast; ring

/-
The intensive pressure F_n / n converges to F_1.
-/
theorem intensivePressure_convergence
    (F : ℕ → ℝ) (hzero : F 0 = 0)
    (hstep : ∀ n, F (n + 1) = F n + F 1) :
    Tendsto (fun n : ℕ => F n / (n : ℝ)) atTop (nhds (F 1)) := by
  -- By induction, we show that F n = n * F 1 for all n.
  have hFn : ∀ n, F n = (n : ℝ) * F 1 := by
    exact ensemblePressure_product_extensivity F hzero hstep;
  exact tendsto_const_nhds.congr' ( by filter_upwards [ Filter.eventually_ne_atTop 0 ] with n hn; rw [ hFn n, mul_div_cancel_left₀ _ ( Nat.cast_ne_zero.mpr hn ) ] )

/-! ## Cross-Domain Bridge: Dynamical Systems -/

/-
Iterated linear map gives power of the scalar.
-/
theorem scalar_linearization_iter (m : ℝ) :
    ∀ n : ℕ, ((fun t : ℝ => m * t)^[n]) = fun t => m ^ n * t := by
  exact fun n => funext fun t => by induction n <;> simp_all +decide [ pow_succ', mul_assoc, Function.iterate_succ_apply' ] ;

/-
Composition of scaling maps gives product of scales.
-/
theorem scaling_composition (s1 s2 : ℝ) :
    (fun t : ℝ => s1 * t) ∘ (fun t : ℝ => s2 * t) = fun t => (s1 * s2) * t := by
  exact funext fun x => by rw [ Function.comp_apply, mul_assoc ] ;

/-! ## Universality Class Properties -/

/-
Same universality class is reflexive.
-/
theorem sameUniversalityClass_refl {G : Type*} [Group G]
    (R : CoarseGraining G) (E : SubgroupEnsemble G) :
    SameUniversalityClass R E E := by
  exact fun b n => rfl

/-
Same universality class is symmetric.
-/
theorem sameUniversalityClass_symm {G : Type*} [Group G]
    (R : CoarseGraining G) (E1 E2 : SubgroupEnsemble G)
    (h : SameUniversalityClass R E1 E2) :
    SameUniversalityClass R E2 E1 := by
  exact fun b n => Eq.symm ( h b n )

/-
Same universality class is transitive.
-/
theorem sameUniversalityClass_trans {G : Type*} [Group G]
    (R : CoarseGraining G) (E1 E2 E3 : SubgroupEnsemble G)
    (h12 : SameUniversalityClass R E1 E2)
    (h23 : SameUniversalityClass R E2 E3) :
    SameUniversalityClass R E1 E3 := by
  exact fun b n => Eq.trans ( h12 b n ) ( h23 b n )

/-
Two fixed points are in the same universality class iff
they have the same pressure at all b.
-/
theorem fixedPoints_universalityClass_iff {G : Type*} [Group G]
    (R : CoarseGraining G) (E1 E2 : SubgroupEnsemble G)
    (hfix1 : IsRGFixedPoint R E1) (hfix2 : IsRGFixedPoint R E2) :
    SameUniversalityClass R E1 E2 ↔
    ∀ b, ensemblePressure b R.complexity E1 =
         ensemblePressure b R.complexity E2 := by
  constructor <;> intro h <;> simp_all +decide [ IsRGFixedPoint, SameUniversalityClass ];
  · exact fun b => by simpa [ hfix1, hfix2 ] using h b 0;
  · intro b n; induction n <;> simp_all +decide [ Function.iterate_fixed ] ;

/-! ## Contractivity -/

/-
If |s(b)| < 1, iterated RG drives pressure to zero.
-/
theorem pressure_contraction
    {G : Type*} [Group G]
    (R : CoarseGraining G) (E : SubgroupEnsemble G) (b : ℝ)
    (hscale : |R.pressureScale b| < 1) :
    Tendsto (fun n => ensemblePressure b R.complexity ((R.map^[n]) E))
      atTop (nhds 0) := by
  convert ( tendsto_pow_atTop_nhds_zero_of_abs_lt_one hscale ) |> Filter.Tendsto.const_mul ( ensemblePressure b R.complexity E ) using 2;
  · rw [ mul_comm, pressure_iterate_of_coarseGraining ];
  · ring

/-! ## Subadditive convergence (Fekete's lemma surrogate) -/

/-
For subadditive sequences bounded by C*n, the limit of a(n)/n exists.
-/
theorem normalized_subadditive_convergence
    (a : ℕ → ℝ) (C : ℝ)
    (hbound : ∀ n, |a n| ≤ C * (n : ℝ))
    (hsubadd : ∀ m n, a (m + n) ≤ a m + a n) :
    ∃ L, Tendsto (fun n : ℕ => a n / (n : ℝ)) atTop (nhds L) := by
  -- By Fekete's lemma, since the sequence is subadditive and bounded, the limit of (a n / n) exists.
  have h_fekete : Filter.Tendsto (fun n => a n / (n : ℝ)) Filter.atTop (nhds (sInf {a n / (n : ℝ) | n > 0})) := by
    refine' tendsto_order.2 ⟨ _, _ ⟩;
    · exact fun x hx => Filter.eventually_atTop.mpr ⟨ 1, fun n hn => lt_of_lt_of_le hx <| csInf_le ⟨ -C, by rintro x ⟨ n, hn, rfl ⟩ ; exact by rw [ le_div_iff₀ <| Nat.cast_pos.mpr hn ] ; linarith [ abs_le.mp <| hbound n ] ⟩ ⟨ n, hn, rfl ⟩ ⟩;
    · intro x hx;
      -- Since $x > \inf \{a_n / n \mid n > 0\}$, there exists some $n > 0$ such that $a_n / n < x$.
      obtain ⟨n, hn_pos, hn_lt⟩ : ∃ n > 0, a n / (n : ℝ) < x := by
        simpa using exists_lt_of_csInf_lt ( by exact ⟨ _, ⟨ 1, by norm_num, rfl ⟩ ⟩ ) hx;
      -- By induction on $k$, we can show that $a_{kn+r} \leq k a_n + a_r$ for any $k \geq 0$ and $0 \leq r < n$.
      have h_induction : ∀ k r : ℕ, 0 ≤ r → r < n → a (k * n + r) ≤ k * a n + a r := by
        intro k r hr₁ hr₂; induction' k with k ih <;> simp_all +decide [ Nat.succ_mul ] ;
        grind [ hsubadd ( k * n + r ) n ];
      -- Choose $k$ large enough such that $\frac{k a_n + a_r}{k n + r} < x$ for all $0 \leq r < n$.
      obtain ⟨k₀, hk₀⟩ : ∃ k₀ : ℕ, ∀ k ≥ k₀, ∀ r : ℕ, 0 ≤ r → r < n → (k * a n + a r) / (k * n + r : ℝ) < x := by
        have h_choose_k : ∀ r : ℕ, 0 ≤ r → r < n → ∃ k₀ : ℕ, ∀ k ≥ k₀, (k * a n + a r) / (k * n + r : ℝ) < x := by
          intro r hr₁ hr₂; rw [ div_lt_iff₀ ] at * <;> try positivity;
          exact ⟨ ⌈ ( x * r - a r ) / ( a n - x * n ) ⌉₊ + 1, fun k hk => by rw [ div_lt_iff₀ ] <;> nlinarith [ Nat.le_ceil ( ( x * r - a r ) / ( a n - x * n ) ), show ( k : ℝ ) ≥ ⌈ ( x * r - a r ) / ( a n - x * n ) ⌉₊ + 1 by exact_mod_cast hk, mul_div_cancel₀ ( x * r - a r ) ( by linarith : ( a n - x * n ) ≠ 0 ), show ( n : ℝ ) > 0 by positivity ] ⟩;
        choose! k₀ hk₀ using h_choose_k;
        exact ⟨ Finset.sup ( Finset.range n ) k₀, fun k hk r hr₁ hr₂ => hk₀ r hr₁ hr₂ k ( le_trans ( Finset.le_sup ( f := k₀ ) ( Finset.mem_range.mpr hr₂ ) ) hk ) ⟩;
      refine' Filter.eventually_atTop.mpr ⟨ k₀ * n, fun m hm => _ ⟩;
      -- Write $m$ as $kn + r$ for some $k \geq k₀$ and $0 \leq r < n$.
      obtain ⟨k, r, hr⟩ : ∃ k r : ℕ, 0 ≤ r ∧ r < n ∧ m = k * n + r := by
        exact ⟨ m / n, m % n, Nat.zero_le _, Nat.mod_lt _ hn_pos, by rw [ Nat.div_add_mod' ] ⟩;
      simp_all +decide [ add_comm ];
      exact lt_of_le_of_lt ( div_le_div_of_nonneg_right ( h_induction k r hr.1 ) ( by positivity ) ) ( hk₀ k ( by nlinarith ) r hr.1 );
  exact ⟨ _, h_fekete ⟩