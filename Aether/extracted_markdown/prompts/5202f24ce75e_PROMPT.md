## YOUR ASSIGNMENT: Functorial Stone duality for closure-generated proof semirings via spectral locales of nuclei

### Core definitions to introduce

Work in the existing EML closure/nucleus infrastructure, and define the spectrum at the level of the lattice/frame of nuclei rather than at the semiring level directly. The right abstraction is: nuclei form a complete lattice; compact nuclei play the role of finitely generated opens; prime nuclei are the points of the spectral space/locale.

You should introduce, as close as possible to the existing `Nucleus` API, the following structures and predicates. Adjust field names to match local conventions, but keep the mathematical content exact.

```lean
/-- A prime point of the lattice of nuclei: proper, and prime with respect to finite meets. -/
structure PrimeNucleus (R : Type u) [Semiring R] [ClosureLike R] where
  val : Nucleus R
  ne_top : val ≠ ⊤
  prime :
    ∀ ⦃I J : Nucleus R⦄, I ⊓ J ≤ val → I ≤ val ∨ J ≤ val
```

If the existing order on nuclei is the reverse of the semantic entailment order, adapt the prime axiom accordingly; the essential condition is primality for compact-open intersections.

Define compact nuclei either by reusing an existing `CompactElement`/`IsCompactElement` predicate on the complete lattice of nuclei, or by introducing:

```lean
def CompactNucleus (R : Type u) [Semiring R] [ClosureLike R] :=
  {I : Nucleus R // IsCompactElement I}
```

Then define the basic compact opens:

```lean
def basicOpen (R : Type u) [Semiring R] [ClosureLike R]
    (K : CompactNucleus R) : Set (PrimeNucleus R) :=
  {p | ¬ ((K : Nucleus R) ≤ p.val)}
```

This is the Stone/Hochster orientation: a compact open is the set of prime points that do not contain the compact element.

You should also define the closure of a set of compact nuclei if needed for the algebraic proof:

```lean
def generatedNucleus (R : Type u) [Semiring R] [ClosureLike R]
    (S : Set (CompactNucleus R)) : Nucleus R := sSup ((fun K => (K : Nucleus R)) '' S)
```

and the spectral specialization order on points:

```lean
def PrimeNucleus.specializes {R : Type u} [Semiring R] [ClosureLike R]
    (p q : PrimeNucleus R) : Prop :=
  q.val ≤ p.val
```

This order should coincide with semantic consequence after you prove the closure theorem below.

---

### Precise theorem targets

#### 1. Basic-open frame laws

Prove the finite-intersection and extremal laws for `basicOpen`. The key exact Lean shape should be:

```lean
theorem basicOpen_top_empty
    (R : Type u) [Semiring R] [ClosureLike R] :
    basicOpen R ⟨⊤, by simpa using isCompactElement_top⟩ = ∅ := by
```

```lean
theorem basicOpen_inf
    (R : Type u) [Semiring R] [ClosureLike R]
    (K L : CompactNucleus R) :
    basicOpen R ⟨(K : Nucleus R) ⊓ (L : Nucleus R), by
      exact IsCompactElement.inf K.property L.property⟩
      =
    basicOpen R K ∩ basicOpen R L := by
```

If the lattice API gives compactness of finite sup rather than finite inf, reverse the order and restate with the lattice operation corresponding to intersection of opens. The mathematically essential law is:
- `D(k ∧ l) = D(k) ∩ D(l)` in the ideal-order convention, or
- `D(k ∨ l) = D(k) ∩ D(l)` in the filter-order convention.

Also prove monotonicity:

```lean
theorem basicOpen_mono
    (R : Type u) [Semiring R] [ClosureLike R]
    {K L : CompactNucleus R}
    (h : (K : Nucleus R) ≤ (L : Nucleus R)) :
    basicOpen R L ⊆ basicOpen R K := by
```

This gives a basis calculus even if full topological infrastructure is not yet available.

#### 2. Prime-extension / spectral separation lemma

This is the decisive engine. Prove a prime-extension theorem for algebraic lattices of nuclei: if `x` is not below `y`, and `x` is compact, then there exists a prime nucleus separating them.

A strong and usable formulation is:

```lean
theorem exists_primeNucleus_separating
    (R : Type u) [Semiring R] [ClosureLike R]
    [IsAlgebraic (Nucleus R)]
    {K I : Nucleus R}
    (hK : IsCompactElement K)
    (hnot : ¬ K ≤ I) :
    ∃ p : PrimeNucleus R, I ≤ p.val ∧ ¬ K ≤ p.val := by
```

A more general but equally good variant is:

```lean
theorem exists_primeNucleus_above_of_not_le
    (R : Type u) [Semiring R] [ClosureLike R]
    [IsAlgebraic (Nucleus R)]
    {x y : Nucleus R}
    (hnot : ¬ x ≤ y) :
    ∃ p : PrimeNucleus R, y ≤ p.val ∧ ¬ x ≤ p.val := by
```

but the compact-source version is the one that feeds directly into the closure theorem.

This is the formal analogue of the prime ideal theorem for distributive/algebraic lattices and is the theorem that turns your nucleus lattice into a genuine spectral object rather than a mere suggestive analogy.

#### 3. Closure theorem / semantic consequence via prime nuclei

Formalize the Stone-separation statement identifying order in the nucleus lattice with membership in all prime points. The exact target should be:

```lean
theorem mem_closure_iff_forall_primeNucleus
    (R : Type u) [Semiring R] [ClosureLike R]
    [IsAlgebraic (Nucleus R)]
    (I J : Nucleus R) :
    I ≤ J ↔ ∀ p : PrimeNucleus R, J ≤ p.val → I ≤ p.val := by
```

This is the order-theoretic Stone duality statement. It says: `I` is semantically forced by `J` iff every prime semantic world containing `J` also contains `I`.

A compact-basis version is even more spectral and may be easier to prove first:

```lean
theorem le_iff_basicOpen_inclusion
    (R : Type u) [Semiring R] [ClosureLike R]
    [IsAlgebraic (Nucleus R)]
    {K : Nucleus R} (hK : IsCompactElement K) {I : Nucleus R} :
    K ≤ I ↔
      ∀ p : PrimeNucleus R, I ≤ p.val → K ≤ p.val := by
```

Then derive the general theorem by expressing arbitrary nuclei as sups of compact nuclei below them.

#### 4. Compact-open basis / spectral surrogate structure

If full `TopologicalSpace`/`SpectralSpace` packaging is too heavy, build a finite-basis surrogate first:

```lean
structure SpectralBasis (α : Type u) where
  IsBasic : Set α → Prop
  inter_basic :
    ∀ {U V}, IsBasic U → IsBasic V → IsBasic (U ∩ V)
  top_basic : IsBasic Set.univ
  compact_like :
    ∀ {U}, IsBasic U → True
```

and instantiate it on `PrimeNucleus R` with basic opens generated by compact nuclei:

```lean
def primeNucleusBasis
    (R : Type u) [Semiring R] [ClosureLike R] :
    SpectralBasis (PrimeNucleus R) := ...
```

If Mathlib’s spectral-space or locale APIs are available enough, instead package:
- a topology generated by `basicOpen R K`,
- a proof that these form a basis closed under finite intersections,
- quasi-compactness of basic opens if feasible,
- `T₀` via prime separation.

Even the surrogate is already mathematically significant if it includes the basis intersection laws and the order-recovery theorem.

#### 5. Functoriality: pullback of prime nuclei

For a closure-preserving semiring morphism, define pullback on nuclei and then on prime nuclei.

A suitable class may look like:

```lean
structure ClosurePreservingHom (R S : Type u)
    [Semiring R] [Semiring S]
    [ClosureLike R] [ClosureLike S] where
  toFun : R →+* S
  map_nucleus :
    Nucleus S → Nucleus R
  map_nucleus_monotone :
    Monotone map_nucleus
  map_nucleus_inf :
    ∀ I J, map_nucleus (I ⊓ J) = map_nucleus I ⊓ map_nucleus J
  map_nucleus_top :
    map_nucleus ⊤ = ⊤
```

Then define:

```lean
def PrimeNucleus.comap
    {R S : Type u} [Semiring R] [Semiring S]
    [ClosureLike R] [ClosureLike S]
    (f : ClosurePreservingHom R S) :
    PrimeNucleus S → PrimeNucleus R := ...
```

and prove the basic-open preimage law:

```lean
theorem preimage_basicOpen
    {R S : Type u} [Semiring R] [Semiring S]
    [ClosureLike R] [ClosureLike S]
    (f : ClosurePreservingHom R S)
    (K : CompactNucleus R) :
    PrimeNucleus.comap f ⁻¹' basicOpen R K
      =
    basicOpen S (compactPullbackAlong f K) := by
```

If compactness preservation under pullback is hard, first prove a weaker statement with a specified compact witness:

```lean
theorem preimage_basicOpen_of_compact_preimage
    ...
    (K : CompactNucleus R)
    (hcomp : IsCompactElement (fwdCompactImage f K)) :
    ...
```

The contravariance is the geometric heart of the duality program.

---

### Proof strategy: concrete attack plan

#### Strategy A: algebraic-lattice Stone duality internalized in the nucleus lattice
This is the most promising route.

1. **Show the lattice of nuclei is the correct algebraic/distributive object.**
   Identify or prove the instances:
   - `CompleteLattice (Nucleus R)`
   - `IsAlgebraic (Nucleus R)` or at least a theorem that every nucleus is the `sSup` of compact nuclei below it.
   - finite distributivity as needed for primality arguments.
   
   The key reduction is: all spectral reasoning should happen in `Nucleus R`, not in `R` itself.

2. **Define prime nuclei and prove basic-open calculus.**
   For `basicOpen`, the proof of finite intersections should be a direct unraveling of primality:
   - `p ∈ basicOpen(K ∧ L)` iff `¬ (K ∧ L ≤ p)`
   - by primality/properness this is equivalent to `¬ (K ≤ p) ∧ ¬ (L ≤ p)`,
   - hence membership in the intersection.
   
   If this equivalence does not line up because of order orientation, swap `⊓`/`⊔` globally in the definition of `basicOpen`.

3. **Prove prime extension by Zorn on separating nuclei.**
   Consider the set
   ```lean
   {J : Nucleus R | I ≤ J ∧ ¬ K ≤ J}
   ```
   ordered by `≤`. Use Zorn to get a maximal `p`. Then prove:
   - `p ≠ ⊤` because `K ≤ ⊤`,
   - if `A ⊓ B ≤ p` and neither `A ≤ p` nor `B ≤ p`, maximality forces `K ≤ p ⊔ A` and `K ≤ p ⊔ B`,
   - distribute compactness/finitary generation to deduce `K ≤ p`, contradiction.
   
   This is the standard Stone prime-extension argument, but the compactness of `K` is what makes the maximality contradiction finitary and formalizable.

4. **Derive the closure theorem from separation.**
   For the nontrivial direction of
   ```lean
   I ≤ J ← ∀ p, J ≤ p → I ≤ p
   ```
   argue contrapositively:
   - assume `¬ I ≤ J`,
   - choose compact `K ≤ I` with `¬ K ≤ J` using algebraicity,
   - apply prime-extension to get `p` with `J ≤ p` and `¬ K ≤ p`,
   - since `K ≤ I`, deduce `¬ I ≤ p`,
   - contradiction.

5. **Recover specialization order and compact-open semantics.**
   Prove that
   ```lean
   p.specializes q ↔ ∀ K, p ∈ basicOpen R K → q ∈ basicOpen R K
   ```
   or the order-reversed variant depending on conventions. This identifies entailment with topological specialization and is the conceptual payoff.

#### Strategy B: ideal completion / distributive-lattice detour
Use this if `Nucleus R` is difficult to show algebraic directly.

1. Define the distributive lattice `K(R)` of compact nuclei.
2. Build prime filters/ideals on `K(R)`.
3. Define a point `p` of the spectrum from a prime filter by
   ```lean
   p := sSup {K compact | K ∈ F}
   ```
   or dually as an infimum/completion.
4. Transfer the compact-open laws from the Stone duality of distributive lattices.
5. Show this completed point is exactly a prime nucleus of the whole lattice.

This route is more infrastructure-heavy but can avoid difficult complete-lattice primality arguments.

#### Strategy C: locale-first, points second
Use if topological packaging becomes unwieldy.

1. Define a frame presented by generators `D(K)` for compact nuclei `K`.
2. Impose relations:
   - `D(⊤) = ⊥`,
   - `D(K ∧ L) = D(K) ∧ D(L)`,
   - `D(⋁ᵢ Kᵢ) = ⋁ᵢ D(Kᵢ)` when compact generation gives such relations.
3. Define points as frame homomorphisms to `Prop`.
4. Show these are equivalent to prime nuclei.
5. Derive `mem_closure_iff_forall_primeNucleus` as soundness/completeness of points.

This is the cleanest conceptually for future locale duality, though less likely to be shortest in Lean.

---

### Key intermediate lemmas to isolate

You should aim to prove and reuse the following lemmas explicitly.

```lean
theorem compact_below_of_not_le
    (R : Type u) [Semiring R] [ClosureLike R]
    [IsAlgebraic (Nucleus R)]
    {I J : Nucleus R} (h : ¬ I ≤ J) :
    ∃ K : Nucleus R, IsCompactElement K ∧ K ≤ I ∧ ¬ K ≤ J := by
```

This is the algebraicity extraction lemma that reduces arbitrary order failure to compact order failure.

```lean
theorem prime_mem_basicOpen_inf_iff
    (R : Type u) [Semiring R] [ClosureLike R]
    (p : PrimeNucleus R) (K L : CompactNucleus R) :
    p ∈ basicOpen R ⟨(K : Nucleus R) ⊓ (L : Nucleus R), _⟩
      ↔ p ∈ basicOpen R K ∧ p ∈ basicOpen R L := by
```

```lean
theorem specializes_iff_basicOpen
    (R : Type u) [Semiring R] [ClosureLike R]
    (p q : PrimeNucleus R) :
    PrimeNucleus.specializes p q ↔
      ∀ K : CompactNucleus R, p ∈ basicOpen R K → q ∈ basicOpen R K := by
```

```lean
theorem t0_primeNucleus
    (R : Type u) [Semiring R] [ClosureLike R]
    [IsAlgebraic (Nucleus R)] :
    ∀ {p q : PrimeNucleus R},
      (∀ K : CompactNucleus R, p ∈ basicOpen R K ↔ q ∈ basicOpen R K) → p = q := by
```

This is the sobriety shadow already visible at the basis level.

---

### Lean implementation guidance

- If `ClosureLike R` is not an existing class, replace it with the concrete typeclass assumptions already used by the EML closure files.
- Reuse Mathlib order-theoretic classes aggressively:
  - `CompleteLattice`
  - `IsCompactElement`
  - `IsAlgebraic`
  - `sSup`
  - `OrderIso`, `GaloisConnection`, `GaloisInsertion` if already present from Lawvere–Galois infrastructure.
- If proving `PrimeNucleus` on the whole lattice is too hard initially, define a temporary notion on compact nuclei only:
  ```lean
  structure PrimeCompactFilter (R : Type u) ... where ...
  ```
  and then extend to full nuclei via algebraic completion.
- Prefer order lemmas over extensional rewrites. Many proofs should become one-line after the right order-theoretic formulation is found.

---

### Why this matters

This is not merely a topological garnish on the existing closure-lattice machinery. It is the missing geometric semantics for proof semirings.

The theorem
```lean
I ≤ J ↔ ∀ p : PrimeNucleus R, J ≤ p.val → I ≤ p.val
```
turns semantic consequence into geometric visibility across prime proof-worlds. That is a genuine Stone duality principle for closure-generated proof semantics. It creates a new bridge between:
- algebraic proof theory, via nuclei and entailment,
- locale/spectral geometry, via compact opens and prime points,
- algorithmics, via compact-open approximants to consequence,
- and the Lawvere-enriched program, by making completion and duality visible at the level of spectra.

This also opens a route distinct from prime-congruence spectra: here the geometry is carried by closure operators/nuclei themselves, which are semantically richer and closer to proof search. The compact opens should correspond to finitely generated proof predicates, so the spectral basis gives an algorithmic finite approximation scheme for entailment regions. That is the computational shadow you should keep in view.

A successful formalization here would make possible:
1. a contravariant duality between closure-preserving proof-semiring morphisms and spectral maps on prime nuclei,
2. a geometric account of semantic consequence as specialization,
3. finite-basis algorithms for approximate proof search using compact opens,
4. and eventual interaction with Lawvere metric completion, where points of the spectrum may be enriched by quantitative semantics.

This is the right next theorem because it converts the current closure/nucleus infrastructure from an algebraic backend into a genuine semantic geometry.

---

### Minimum viable fallback if the full theorem is too ambitious

If full spectral packaging stalls, prove the following exact reduced target first:

```lean
theorem compact_separation_by_primeNucleus
    (R : Type u) [Semiring R] [ClosureLike R]
    [IsAlgebraic (Nucleus R)]
    {K I : Nucleus R}
    (hK : IsCompactElement K)
    (hnot : ¬ K ≤ I) :
    ∃ p : PrimeNucleus R, I ≤ p.val ∧ ¬ K ≤ p.val := by
```

and then

```lean
theorem le_iff_forall_primeNucleus_of_compact
    (R : Type u) [Semiring R] [ClosureLike R]
    [IsAlgebraic (Nucleus R)]
    {K I : Nucleus R}
    (hK : IsCompactElement K) :
    K ≤ I ↔ ∀ p : PrimeNucleus R, I ≤ p.val → K ≤ p.val := by
```

These two lemmas already constitute the hard mathematical core. Everything else is packaging.

---

### Deliverables

1. Definitions:
   - `PrimeNucleus`
   - `CompactNucleus` or reuse of compact-element subtype
   - `basicOpen`
   - specialization order
   - functorial pullback/comap on prime nuclei

2. Theorems:
   - basic-open finite intersection law
   - prime-extension separation lemma
   - `mem_closure_iff_forall_primeNucleus`
   - basis-level `T₀`/order recovery
   - preimage of basic opens under comap

3. A structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, for example:
   - full locale/frame packaging and sobriety,
   - duality with a category of coherent proof-semiring completions,
   - algorithm extraction for compact-open entailment approximants,
   - interaction with Lawvere metric/entropy completion,
   - comparison with prime-congruence and tropical spectra.

### Catalog Reference Files
            @Computation/DensityTheory.lean
```lean
import Mathlib

/-! # CatalogBuild.Computation.DensityTheory

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 15
-/


noncomputable section

/-- The EML operation. -/
def EMLd (a b : ℝ) : ℝ := Real.exp a - Real.log b

/-- EML closure at depth n: start from seed set S and apply EMLd n times. -/
def EMLClosure : ℕ → Set ℝ → Set ℝ
  | 0, S => S
  | n + 1, S => EMLClosure n S ∪ {z | ∃ a ∈ EMLClosure n S, ∃ b ∈ EMLClosure n S, z = EMLd a b}

/-- The full EML closure (union over all depths). -/
def fullEMLClosure (S : Set ℝ) : Set ℝ := ⋃ n, EMLClosure n S




/-- 1 is in the seed set. -/
theorem one_in_closure : (1 : ℝ) ∈ EMLClosure 0 {1} := by
  simp [EMLClosure]




/-- EML closure is monotone in depth. -/
theorem EMLClosure_mono (S : Set ℝ) (n : ℕ) :
    EMLClosure n S ⊆ EMLClosure (n + 1) S := by
  intro x hx
  simp [EMLClosure]
  exact Or.inl hx




/-- Log-split: EML(x, y·z) = EML(x, y) - ln(z) for y, z > 0. -/
theorem EMLd_log_split (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    EMLd x (y * z) = EMLd x y - Real.log z := by
  simp [EMLd, Real.log_mul hy.ne' hz.ne']; ring




/-- EML(x, 1) = exp(x). -/
theorem EMLd_exp (x : ℝ) : EMLd x 1 = Real.exp x := by
  simp [EMLd, Real.log_one]




/-- EML(0, x) = 1 - ln(x). -/
theorem EMLd_one_minus_log (x : ℝ) : EMLd 0 x = 1 - Real.log x := by
  simp [EMLd]




/-- EML(0, x) maps values in (1, e) to (0, 1). -/
theorem EMLd_maps_to_unit_interval (x : ℝ) (hx1 : 1 < x) (hxe : x < Real.exp 1) :
    0 < EMLd 0 x ∧ EMLd 0 x < 1 := by
  constructor
  · simp [EMLd]
    have : Real.log x < 1 := by
      rwa [← Real.log_exp 1, Real.log_lt_log_iff (by linarith) (Real.exp_pos 1)]
    linarith
  · simp [EMLd]
    linarith [Real.log_pos hx1]




/-- exp maps any positive value to a value > 1. -/
theorem EMLd_amplifies (x : ℝ) (hx : 0 < x) :
    EMLd x 1 > 1 := by
  simp [EMLd, Real.log_one]
  linarith [Real.add_one_le_exp x]




/-- The composition EML(EML(0, x), 1) = exp(1 - ln(x)) = e/x for x > 0. -/
theorem EMLd_inv_scaled (x : ℝ) (hx : 0 < x) :
    EMLd (EMLd 0 x) 1 = Real.exp 1 / x := by
  simp [EMLd, Real.log_one, Real.exp_sub, Real.exp_log hx]




/-- ln recovery: EML(0, exp(EML(0, x))) = ln(x). -/
theorem EMLd_recovers_ln (x : ℝ) :
    EMLd 0 (Real.exp (EMLd 0 x)) = Real.log x := by
  simp [EMLd, Real.log_exp]




/-- Double negation: EML(0, exp(EML(0, exp(x)))) = x. -/
theorem EMLd_double_neg (x : ℝ) :
    EMLd 0 (Real.exp (EMLd 0 (Real.exp x))) = x := by
  simp [EMLd, Real.log_exp]




/-- Shift identity: EML(x + c, 1) = exp(c) · exp(x). -/
theorem EMLd_shift (x c : ℝ) :
    EMLd (x + c) 1 = Real.exp c * Real.exp x := by
  simp [EMLd, Real.log_one, Real.exp_add, mul_comm]




/-- [Section: # CatalogBuild.Computation.DensityTheory
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 15] -/
theorem e_irrational : Irrational (Real.exp 1) := by
  by_contra h;
  -- Assume that $e$ is rational, so there exist positive integers $p$ and $q$ such that $e = p/q$.
  obtain ⟨p, q, hpq⟩ : ∃ p q : ℕ, p > 0 ∧ q > 0 ∧ Real.exp 1 = p / q := by
    -- Since $e$ is not irrational, it must be rational. Therefore, there exist positive integers $p$ and $q$ such that $e = p/q$.
    obtain ⟨p, q, hpq⟩ : ∃ p q : ℤ, p > 0 ∧ q > 0 ∧ Real.exp 1 = p / q := by
      obtain ⟨ q, hq ⟩ := Classical.not_not.mp h;
      exact ⟨ q.num, q.den, mod_cast Rat.num_pos.mpr ( show 0 < q by exact_mod_cast hq.symm ▸ Real.exp_pos 1 ), mod_cast q.pos, by simpa only [ Rat.cast_def ] using hq.symm ⟩;
    cases p <;> cases q <;> aesop;
  -- Multiply both sides of the equation $e = p/q$ by $q!$ to obtain $q! \cdot e = p \cdot (q-1)! + p \cdot (q-2)! + \cdots + p + \frac{p}{q+1} + \cdots$.
  have h_mul_factorial : q.factorial * Real.exp 1 = ∑ k ∈ Finset.range (q + 1), (q.factorial : ℝ) / (k.factorial : ℝ) + ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1 + k).factorial : ℝ) := by
    have h_mul_factorial : q.factorial * Real.exp 1 = ∑' k : ℕ, (q.factorial : ℝ) / ((k).factorial : ℝ) := by
      norm_num [ div_eq_mul_inv, Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum ];
      rw [ NormedSpace.exp_eq_tsum_div, ← tsum_mul_left ] ; exact tsum_congr fun _ => by ring;
    rw [ h_mul_factorial, ← Summable.sum_add_tsum_nat_add ];
    congr! 2;
    · ac_rfl;
    · exact Summable.mul_left _ <| by simpa using Real.summable_pow_div_factorial 1;
  -- The series $\sum_{k=q+1}^{\infty} \frac{q!}{k!}$ is strictly less than 1.
  have h_series_lt_one : ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1 + k).factorial : ℝ) < 1 := by
    -- We can bound the series $\sum_{k=q+1}^{\infty} \frac{q!}{k!}$ above by a geometric series.
    have h_geo_series : ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1 + k).factorial : ℝ) ≤ ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1).factorial : ℝ) * (1 / (q + 2)) ^ k := by
      refine' Summable.tsum_le_tsum _ _ _;
      · field_simp;
        intro i; rw [ div_pow ] ; rw [ mul_div, le_div_iff₀ ] <;> norm_cast <;> induction' i with i ih <;> norm_num [ Nat.factorial, pow_succ' ] at *;
        nlinarith [ Nat.factorial_succ ( q + 1 + i ) ];
-- ... (truncated, full file has 181 lines)
```


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Bridges
Research mode: prove
