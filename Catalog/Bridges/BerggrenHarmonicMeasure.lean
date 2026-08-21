import Mathlib

/-!
# Harmonic measure on the boundary of the Berggren tree

The Berggren tree of primitive Pythagorean triples is the free rooted ternary tree on the
three Berggren moves `L, M, R` (the catalog's `HyperbolicBerggrenGeodesics.Move`, whose
words `run : List Move → ℕ × ℕ` enumerate every primitive triple exactly once).  Its
*boundary* — the set of infinite descending paths — is therefore the space of infinite words
over a three letter alphabet,

`Bdry = ℕ → Fin 3`,

the **3-adic Cantor set**.  This file develops the probabilistic theory of the tree:

* `cyl n v` : the cylinder set of boundary points agreeing with `v` on the first `n` letters
  (the shadow of a depth-`n` node of the tree).
* `ProbVec` : a strictly positive probability vector `(p₁, p₂, p₃)` on the three moves.
* `bernoulli P` : the Bernoulli (product) measure on the boundary, built with Mathlib's
  infinite product measure `MeasureTheory.Measure.infinitePi`.
* `IsHarmonic P ν` : the *harmonicity* (stationarity, self-similarity) equation
  `ν = ∑ a, pₐ · (consₐ)_* ν` characterising the hitting distribution on the boundary of the
  random walk which, at each step, appends the letter `a` with probability `pₐ`.

## Main results

* `bernoulli_cyl` : the product measure of a depth-`n` cylinder is `∏_{i<n} p_{v i}`.
* `ext_of_cyl_eq` : two probability measures on the boundary agreeing on all cylinders are
  equal (the cylinders form a π-system generating the product σ-algebra:
  `isPiSystem_cylinders`, `generateFrom_cylinders`).
* `IsHarmonic.cyl_eq` : *every* harmonic measure gives a cylinder its Bernoulli mass.
* `bernoulli_isHarmonic` : the Bernoulli measure is harmonic.
* `harmonic_iff_bernoulli`, `existsUnique_harmonic` : **the harmonic measure of the Berggren
  random walk exists, is unique, and is exactly the Bernoulli product measure** — the main
  conjecture of this cycle, in the strong "unique stationary measure" form.
* `bernoulli_uniform_cyl` : for the uniform walk the harmonic measure of a depth-`n`
  cylinder is `3^{-n}`, i.e. it is the Hausdorff/Cantor measure of the 3-adic boundary.
-/

namespace BerggrenHarmonic

open MeasureTheory Set MeasurableSpace
open scoped ENNReal

/-- The three Berggren moves, as an alphabet.  (`0 ↔ L`, `1 ↔ M`, `2 ↔ R` for the catalog's
`HyperbolicBerggrenGeodesics.Move`.) -/
abbrev Letter := Fin 3

/-- The boundary of the Berggren tree: infinite words in the three moves, i.e. the 3-adic
Cantor set. -/
abbrev Bdry := ℕ → Letter

/-- The cylinder set of depth `n` through `v`: all boundary points whose first `n` letters
agree with those of `v`.  This is the shadow of the depth-`n` node `run (v 0 :: … :: v (n-1))`
of the Berggren tree. -/
def cyl (n : ℕ) (v : Bdry) : Set Bdry := {x | ∀ i < n, x i = v i}

/-- Prepending a letter: the boundary map induced by the Berggren move `a`. -/
def cons (a : Letter) (x : Bdry) : Bdry
  | 0 => a
  | (k + 1) => x k

@[simp] lemma cons_zero (a : Letter) (x : Bdry) : cons a x 0 = a := rfl

@[simp] lemma cons_succ (a : Letter) (x : Bdry) (k : ℕ) : cons a x (k + 1) = x k := rfl

lemma measurable_cons (a : Letter) : Measurable (cons a) := by
  apply measurable_pi_lambda
  intro n
  cases n with
  | zero => exact measurable_const
  | succ k => exact measurable_pi_apply k

@[simp] lemma cyl_zero (v : Bdry) : cyl 0 v = univ := by
  ext x; simp [cyl]

/-- A cylinder is the box of the singletons of its letters. -/
lemma cyl_eq_pi (n : ℕ) (v : Bdry) :
    cyl n v = (↑(Finset.range n) : Set ℕ).pi (fun i => {v i}) := by
  ext x
  simp [cyl, Set.mem_pi]

lemma measurableSet_cyl (n : ℕ) (v : Bdry) : MeasurableSet (cyl n v) := by
  rw [cyl_eq_pi]
  exact MeasurableSet.pi (Finset.range n).countable_toSet (fun i _ => MeasurableSet.singleton _)

/-- The shift of a word. -/
def tail (v : Bdry) : Bdry := fun k => v (k + 1)

/-- Pulling a depth-`(n+1)` cylinder back along the move `a` gives the depth-`n` cylinder of
the shifted word when `a` is the first letter, and the empty set otherwise. -/
lemma preimage_cons_cyl_succ (a : Letter) (n : ℕ) (v : Bdry) :
    cons a ⁻¹' cyl (n + 1) v = if a = v 0 then cyl n (tail v) else ∅ := by
  by_cases h : a = v 0
  · simp only [h]
    ext x
    constructor
    · intro hx i hi
      have := hx (i + 1) (by omega)
      simpa [tail] using this
    · intro hx i hi
      cases i with
      | zero => simp
      | succ k =>
          have : x k = tail v k := hx k (by omega)
          simpa [tail] using this
  · simp only [h]
    ext x
    constructor
    · intro hx
      exact absurd (by simpa [cons] using hx 0 (by omega)) h
    · intro hx
      exact hx.elim

/-! ## Probability vectors and the Bernoulli measure -/

/-- A strictly positive probability vector on the three Berggren moves. -/
structure ProbVec where
  /-- the weights -/
  p : Letter → ℝ
  /-- strict positivity -/
  pos : ∀ a, 0 < p a
  /-- normalisation -/
  sum_eq : ∑ a, p a = 1

namespace ProbVec

variable (P : ProbVec)

lemma le_one (a : Letter) : P.p a ≤ 1 := by
  have h := P.sum_eq
  have : ∀ b ∈ Finset.univ, 0 ≤ P.p b := fun b _ => (P.pos b).le
  calc P.p a ≤ ∑ b, P.p b := Finset.single_le_sum this (Finset.mem_univ a)
    _ = 1 := h

/-- The one-step distribution of the walk, as a `PMF` on the three moves. -/
noncomputable def pmf : PMF Letter :=
  PMF.ofFintype (fun a => ENNReal.ofReal (P.p a)) (by
    rw [← ENNReal.ofReal_sum_of_nonneg (fun a _ => (P.pos a).le), P.sum_eq, ENNReal.ofReal_one])

@[simp] lemma pmf_apply (a : Letter) : P.pmf a = ENNReal.ofReal (P.p a) := by
  simp [pmf]

/-- The one-step distribution as a measure on the alphabet. -/
noncomputable def stepMeasure : Measure Letter := P.pmf.toMeasure

instance : IsProbabilityMeasure P.stepMeasure := by
  unfold stepMeasure; infer_instance

@[simp] lemma stepMeasure_singleton (a : Letter) :
    P.stepMeasure {a} = ENNReal.ofReal (P.p a) := by
  rw [stepMeasure, PMF.toMeasure_apply_singleton _ _ (MeasurableSet.singleton a), pmf_apply]

end ProbVec

/-- The Bernoulli (product) measure on the 3-adic boundary attached to the weights `P`. -/
noncomputable def bernoulli (P : ProbVec) : Measure Bdry :=
  Measure.infinitePi (fun _ : ℕ => P.stepMeasure)

instance (P : ProbVec) : IsProbabilityMeasure (bernoulli P) := by
  unfold bernoulli; infer_instance

/-- The mass a probability vector assigns to a depth-`n` cylinder. -/
noncomputable def wmass (P : ProbVec) (n : ℕ) (v : Bdry) : ℝ≥0∞ :=
  ∏ i ∈ Finset.range n, ENNReal.ofReal (P.p (v i))

@[simp] lemma wmass_zero (P : ProbVec) (v : Bdry) : wmass P 0 v = 1 := by
  simp [wmass]

lemma wmass_succ (P : ProbVec) (n : ℕ) (v : Bdry) :
    wmass P (n + 1) v = ENNReal.ofReal (P.p (v 0)) * wmass P n (tail v) := by
  unfold wmass
  rw [Finset.prod_range_succ']
  simp [tail, mul_comm]

/-- **The Bernoulli mass of a cylinder is the product of the letter probabilities.** -/
theorem bernoulli_cyl (P : ProbVec) (n : ℕ) (v : Bdry) :
    bernoulli P (cyl n v) = wmass P n v := by
  rw [cyl_eq_pi, bernoulli,
    Measure.infinitePi_pi _ (fun i _ => MeasurableSet.singleton (v i))]
  simp [wmass]

/-! ## Cylinders generate: a uniqueness tool -/

/-- The collection of all cylinder sets. -/
def cylinders : Set (Set Bdry) := {S | ∃ n v, S = cyl n v}

lemma cyl_mem_cylinders (n : ℕ) (v : Bdry) : cyl n v ∈ cylinders := ⟨n, v, rfl⟩

/-- If a point lies in two cylinders, the deeper one is contained in the shallower one. -/
lemma cyl_subset_of_mem {n m : ℕ} {v w : Bdry} (hnm : n ≤ m) {x : Bdry}
    (hxv : x ∈ cyl n v) (hxw : x ∈ cyl m w) : cyl m w ⊆ cyl n v := by
  intro y hy i hi
  have h1 : y i = w i := hy i (lt_of_lt_of_le hi hnm)
  have h2 : x i = w i := hxw i (lt_of_lt_of_le hi hnm)
  have h3 : x i = v i := hxv i hi
  rw [h1, ← h2, h3]

lemma isPiSystem_cylinders : IsPiSystem cylinders := by
  rintro S ⟨n, v, rfl⟩ T ⟨m, w, rfl⟩ ⟨x, hxv, hxw⟩
  rcases le_total n m with h | h
  · have hsub := cyl_subset_of_mem h hxv hxw
    have : cyl n v ∩ cyl m w = cyl m w := by
      apply Set.inter_eq_self_of_subset_right hsub
    rw [this]
    exact cyl_mem_cylinders m w
  · have hsub := cyl_subset_of_mem h hxw hxv
    have : cyl n v ∩ cyl m w = cyl n v := by
      apply Set.inter_eq_self_of_subset_left hsub
    rw [this]
    exact cyl_mem_cylinders n v

/-- Extend a finite word to an infinite one by padding with the letter `0`. -/
def extend (n : ℕ) (u : Fin n → Letter) : Bdry := fun k => if h : k < n then u ⟨k, h⟩ else 0

/-- The event "the `i`-th letter is `a`" is a finite union of cylinders. -/
lemma coord_eq_eq_iUnion (i : ℕ) (a : Letter) :
    {x : Bdry | x i = a} =
      ⋃ u : {u : Fin (i + 1) → Letter // u ⟨i, Nat.lt_succ_self i⟩ = a},
        cyl (i + 1) (extend (i + 1) u.1) := by
  ext x
  constructor
  · intro hx
    refine mem_iUnion.2 ⟨⟨fun j => x j, by simpa using hx⟩, ?_⟩
    intro k hk
    simp [extend, hk]
  · intro hx
    obtain ⟨u, hu⟩ := mem_iUnion.1 hx
    have h2 := hu i (Nat.lt_succ_self i)
    simp only [mem_setOf_eq]
    rw [h2]
    simpa [extend] using u.2

lemma generateFrom_cylinders :
    MeasurableSpace.generateFrom cylinders = (inferInstance : MeasurableSpace Bdry) := by
  apply le_antisymm
  · apply MeasurableSpace.generateFrom_le
    rintro S ⟨n, v, rfl⟩
    exact measurableSet_cyl n v
  · rw [MeasurableSpace.le_def]
    have hcoord : ∀ i : ℕ, Measurable[MeasurableSpace.generateFrom cylinders]
        (fun x : Bdry => x i) := by
      intro i
      refine @measurable_to_countable' Letter Bdry _ _ (MeasurableSpace.generateFrom cylinders)
        _ (fun a => ?_)
      have hpre : (fun x : Bdry => x i) ⁻¹' {a} = {x : Bdry | x i = a} := rfl
      rw [hpre, coord_eq_eq_iUnion i a]
      refine @MeasurableSet.iUnion _ _ (MeasurableSpace.generateFrom cylinders) _ _ (fun u => ?_)
      exact MeasurableSpace.measurableSet_generateFrom (cyl_mem_cylinders _ _)
    intro s hs
    have hm : Measurable[MeasurableSpace.generateFrom cylinders] (id : Bdry → Bdry) :=
      (@measurable_pi_iff Bdry ℕ (fun _ => Letter) (MeasurableSpace.generateFrom cylinders)
        _ id).2 hcoord
    exact hm hs

/-- **Cylinders determine a measure.**  Two probability measures on the 3-adic boundary that
agree on every cylinder are equal. -/
theorem ext_of_cyl_eq {μ ν : Measure Bdry} [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (h : ∀ n v, μ (cyl n v) = ν (cyl n v)) : μ = ν := by
  refine MeasureTheory.ext_of_generate_finite cylinders generateFrom_cylinders.symm
    isPiSystem_cylinders ?_ ?_
  · rintro S ⟨n, v, rfl⟩
    exact h n v
  · rw [measure_univ, measure_univ]

/-! ## Harmonicity -/

/-- **The harmonicity (stationarity) equation.**  The hitting measure of the random walk that
appends the Berggren move `a` with probability `pₐ` must satisfy
`ν = ∑ₐ pₐ · (consₐ)_* ν`: conditioning on the first move decomposes the boundary into the
three shadows of the children of the root. -/
def IsHarmonic (P : ProbVec) (ν : Measure Bdry) : Prop :=
  ν = ∑ a : Letter, ENNReal.ofReal (P.p a) • ν.map (cons a)

lemma isHarmonic_apply {P : ProbVec} {ν : Measure Bdry} (h : IsHarmonic P ν)
    {S : Set Bdry} (hS : MeasurableSet S) :
    ν S = ∑ a : Letter, ENNReal.ofReal (P.p a) * ν (cons a ⁻¹' S) := by
  conv_lhs => rw [h]
  rw [Measure.coe_finset_sum]
  simp only [Finset.sum_apply, Measure.smul_apply, smul_eq_mul]
  refine Finset.sum_congr rfl (fun a _ => ?_)
  rw [Measure.map_apply (measurable_cons a) hS]

/-- A harmonic measure assigns to each cylinder exactly its Bernoulli mass. -/
theorem IsHarmonic.cyl_eq {P : ProbVec} {ν : Measure Bdry} [IsProbabilityMeasure ν]
    (h : IsHarmonic P ν) (n : ℕ) (v : Bdry) : ν (cyl n v) = wmass P n v := by
  induction n generalizing v with
  | zero => rw [cyl_zero, wmass_zero, measure_univ]
  | succ n ih =>
      rw [isHarmonic_apply h (measurableSet_cyl (n + 1) v)]
      have hterm : ∀ a : Letter, ENNReal.ofReal (P.p a) * ν (cons a ⁻¹' cyl (n + 1) v)
          = if a = v 0 then ENNReal.ofReal (P.p (v 0)) * wmass P n (tail v) else 0 := by
        intro a
        rw [preimage_cons_cyl_succ]
        by_cases ha : a = v 0
        · subst ha
          rw [if_pos rfl, if_pos rfl, ih (tail v)]
        · simp [ha]
      rw [Finset.sum_congr rfl (fun a _ => hterm a), Finset.sum_ite_eq' Finset.univ (v 0)]
      simp [wmass_succ]

/-- The Bernoulli measure is harmonic. -/
theorem bernoulli_isHarmonic (P : ProbVec) : IsHarmonic P (bernoulli P) := by
  set ν : Measure Bdry := ∑ a : Letter, ENNReal.ofReal (P.p a) • (bernoulli P).map (cons a)
    with hν
  have hval : ∀ (S : Set Bdry), MeasurableSet S →
      ν S = ∑ a : Letter, ENNReal.ofReal (P.p a) * bernoulli P (cons a ⁻¹' S) := by
    intro S hS
    rw [hν, Measure.coe_finset_sum]
    simp only [Finset.sum_apply, Measure.smul_apply, smul_eq_mul]
    refine Finset.sum_congr rfl (fun a _ => ?_)
    rw [Measure.map_apply (measurable_cons a) hS]
  have huniv : ν univ = 1 := by
    rw [hval univ MeasurableSet.univ]
    simp only [Set.preimage_univ, measure_univ, mul_one]
    rw [← ENNReal.ofReal_sum_of_nonneg (fun a _ => (P.pos a).le), P.sum_eq, ENNReal.ofReal_one]
  have hprob : IsProbabilityMeasure ν := ⟨huniv⟩
  have hcyl : ∀ n v, bernoulli P (cyl n v) = ν (cyl n v) := by
    intro n v
    rw [bernoulli_cyl]
    cases n with
    | zero => rw [cyl_zero, wmass_zero, huniv]
    | succ n =>
        rw [hval _ (measurableSet_cyl (n + 1) v)]
        have hterm : ∀ a : Letter, ENNReal.ofReal (P.p a) * bernoulli P (cons a ⁻¹' cyl (n+1) v)
            = if a = v 0 then ENNReal.ofReal (P.p (v 0)) * wmass P n (tail v) else 0 := by
          intro a
          rw [preimage_cons_cyl_succ]
          by_cases ha : a = v 0
          · subst ha
            rw [if_pos rfl, if_pos rfl, bernoulli_cyl]
          · simp [ha]
        rw [Finset.sum_congr rfl (fun a _ => hterm a), Finset.sum_ite_eq' Finset.univ (v 0)]
        simp [wmass_succ]
  exact @ext_of_cyl_eq _ _ inferInstance hprob hcyl

/-- **Main theorem: the harmonic measure of the Berggren random walk is Bernoulli.**  A
probability measure on the 3-adic boundary of the Berggren tree is harmonic for the weights
`(p₁,p₂,p₃)` if and only if it is the Bernoulli product measure. -/
theorem harmonic_iff_bernoulli (P : ProbVec) (ν : Measure Bdry) [IsProbabilityMeasure ν] :
    IsHarmonic P ν ↔ ν = bernoulli P := by
  constructor
  · intro h
    refine ext_of_cyl_eq (fun n v => ?_)
    rw [h.cyl_eq n v, bernoulli_cyl]
  · rintro rfl
    exact bernoulli_isHarmonic P

/-- **Existence and uniqueness of the harmonic measure.** -/
theorem existsUnique_harmonic (P : ProbVec) :
    ∃! ν : Measure Bdry, IsProbabilityMeasure ν ∧ IsHarmonic P ν := by
  refine ⟨bernoulli P, ⟨inferInstance, bernoulli_isHarmonic P⟩, ?_⟩
  rintro ν ⟨hprob, hharm⟩
  exact (@harmonic_iff_bernoulli P ν hprob).1 hharm

/-! ## The uniform walk and the Cantor measure -/

/-- The uniform (fair) Berggren walk. -/
noncomputable def uniformVec : ProbVec where
  p := fun _ => 1 / 3
  pos := fun _ => by norm_num
  sum_eq := by norm_num

/-- For the fair walk the harmonic measure of a depth-`n` cylinder is `3^{-n}`: the harmonic
measure is the natural Cantor (Hausdorff) measure of the 3-adic boundary. -/
theorem bernoulli_uniform_cyl (n : ℕ) (v : Bdry) :
    bernoulli uniformVec (cyl n v) = (ENNReal.ofReal (1 / 3)) ^ n := by
  rw [bernoulli_cyl]
  simp [wmass, uniformVec]

end BerggrenHarmonic