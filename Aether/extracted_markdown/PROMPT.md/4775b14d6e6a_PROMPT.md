## Assignment: Tropical Brill–Noether Theory as a Formal Bridge Between Chip-Firing, Moduli, and Classical Geometry

You are not being asked for a routine formalization of a known equivalence. You are being asked to carve out the Lean 4 foundation for a **tropical Brill–Noether machine**: a formal framework in which divisor rank on metric graphs, the Brill–Noether number
\[
\rho(g,r,d)=g-(r+1)(g-d+r),
\]
and a certified bridge to classical algebraic geometry become mathematically executable.

The transformative target is this: formalize a nontrivial tropical avatar of the Brill–Noether theorem, together with enough infrastructure that later work can attack tropical Petri, tropical Clifford, specialization from algebraic curves, and algorithmic divisor search.

Build on the catalog where it genuinely helps:
- use `tropical_classical_bridge` as the seed for a theorem schema connecting tropical and classical existence statements,
- use `tropical_rational_eq_iff_crossmul` whenever tropical rational identities arise in divisor/chip-firing normal forms,
- use structural tropical rank theorems (`tropical_rank_one_iff_additive_separable`, `tropFactorRank_bound_via_tropical_rank`) if you encode divisor configurations or linear systems via tropical matrices,
- use nontrivial proof patterns only; avoid vacuous decidability-based statements.

You must create at least one genuinely new definition and prove at least 3 substantial theorems.

---

## Core Vision

The classical Brill–Noether theorem says a general smooth projective curve of genus `g` possesses a `g^r_d` iff `ρ(g,r,d) ≥ 0`. In tropical geometry, the analogous statement for a **general tropical curve** is subtle: “general” must be represented combinatorially or by an open dense condition in moduli, and rank must be formalized via chip-firing / linear equivalence.

Your Lean development should therefore target a **precise certified partial Brill–Noether package**:

1. a formal notion of tropical curve model sufficient for divisor theory,
2. a formal notion of divisor rank and Brill–Noether nonemptiness,
3. a theorem that **necessity** of `ρ ≥ 0` follows from a generality hypothesis,
4. a theorem that for a canonical family of generic tropical curves (e.g. chains of loops with generic edge lengths), **sufficiency** holds when `ρ ≥ 0`,
5. a bridge theorem transferring tropical existence to a classical existence schema or conversely expressing tropicalization/specialization monotonicity.

If full generality for all tropical curves is too large for one cycle, do not weaken into triviality. Instead prove the breakthrough family theorem for **generic chains of loops**, but package definitions so the general theorem becomes a natural next step.

---

## New Definitions You Should Introduce

At minimum define one new concept not already in the catalog. Preferably define all of the following.

### 1. Brill–Noether number
```lean
def brillNoetherNumber (g r d : ℤ) : ℤ :=
  g - (r + 1) * (g - d + r)
```

Natural number variant:
```lean
def brillNoetherNumberNat (g r d : ℕ) : ℤ :=
  (g : ℤ) - ((r : ℤ) + 1) * ((g : ℤ) - (d : ℤ) + (r : ℤ))
```

### 2. Tropical divisor profile / existence predicate
Abstract the existence statement before full metric graph infrastructure is complete:
```lean
class TropicalCurve (C : Type _) where
  genus : C → ℕ

class HasDivisorRank (C : Type _) where
  Divisor : Type _
  curveOf : Divisor → C
  degree : Divisor → ℤ
  rank : Divisor → ℤ

def ExistsDivisorOfDegreeRank
    {C : Type _} [TropicalCurve C] [HasDivisorRank C]
    (X : C) (d r : ℤ) : Prop :=
  ∃ D : HasDivisorRank.Divisor, HasDivisorRank.curveOf D = X ∧
    HasDivisorRank.degree D = d ∧ HasDivisorRank.rank D ≥ r
```

### 3. Generic tropical curve family
For a tractable theorem, encode a family such as chains of loops with generic edge lengths:
```lean
structure ChainOfLoops where
  g : ℕ
  lengths : Fin (2 * g) → ℝ
  generic : Pairwise fun i j => i ≠ j → lengths i ≠ lengths j
```
or, if pairwise distinctness is too strong, define a genericity predicate abstractly:
```lean
def GenericChainOfLoops (Γ : ChainOfLoops) : Prop := ...
```

### 4. Brill–Noether locus predicate
```lean
def InBrillNoetherLocus
    {C : Type _} [TropicalCurve C] [HasDivisorRank C]
    (X : C) (g d r : ℤ) : Prop :=
  (TropicalCurve.genus X : ℤ) = g ∧ ExistsDivisorOfDegreeRank X d r
```

### 5. Specialization monotonicity schema
This is the key cross-domain bridge:
```lean
def SpecializesRankNondecreasing
    {Alg Trop : Type _}
    (sp : Alg → Trop) (rankA : Alg → ℤ) (rankT : Trop → ℤ) : Prop :=
  ∀ x, rankT (sp x) ≥ rankA x
```

---

## Precise Theorem Targets

You need at least 3 serious theorems. The following package is the right level of ambition.

### Theorem 1: Arithmetic structure of the Brill–Noether threshold
This is not the main theorem, but it gives the algebraic control needed later.

```lean
theorem brillNoetherNumber_mono_degree
    {g r d₁ d₂ : ℕ} (h : d₁ ≤ d₂) :
    brillNoetherNumberNat g r d₁ ≤ brillNoetherNumberNat g r d₂ := by
  ...
```

Why this matters: it certifies the monotonicity of the nonemptiness threshold in degree and is foundational for any search algorithm over divisors.

A stronger useful theorem:
```lean
theorem brillNoetherNumber_nonneg_of_degree_large
    {g r d : ℕ} (h : g + r ≤ d) :
    0 ≤ brillNoetherNumberNat g r d := by
  ...
```

This theorem should require real integer arithmetic, coercion management, and a multi-step `calc` / linear-arithmetic proof, not a trivial simplification.

---

### Theorem 2: Necessity direction for tropical Brill–Noether under a genericity axiom
If you cannot formalize full moduli-genericity, state a precise theorem for an abstract class of “Brill–Noether general” tropical curves.

```lean
class BrillNoetherGeneral {C : Type _} [TropicalCurve C] [HasDivisorRank C] (X : C) : Prop where
  rho_nonneg_of_exists :
    ∀ {d r : ℤ}, ExistsDivisorOfDegreeRank X d r →
      0 ≤ brillNoetherNumber (TropicalCurve.genus X) r d
```

Then prove:
```lean
theorem rho_nonneg_of_exists_divisor
    {C : Type _} [TropicalCurve C] [HasDivisorRank C]
    (X : C) [BrillNoetherGeneral X] {d r : ℤ}
    (h : ExistsDivisorOfDegreeRank X d r) :
    0 ≤ brillNoetherNumber (TropicalCurve.genus X) r d := by
  ...
```

This theorem is abstract but meaningful only if followed by a concrete instance for a nontrivial family.

---

### Theorem 3: Sufficiency on a concrete generic family (chains of loops)
This is the real breakthrough theorem you should aim to formalize in a mathematically honest restricted form.

```lean
axiom chainOfLoops_has_divisor_of_rho_nonneg
  (Γ : ChainOfLoops) (hgen : GenericChainOfLoops Γ)
  {d r : ℤ}
  (hrho : 0 ≤ brillNoetherNumber (Γ.g) r d) :
  ExistsDivisorOfDegreeRank Γ d r
```

But do not leave it as an axiom in the final target. Replace with a theorem if at all possible:

```lean
theorem chainOfLoops_brill_noether_sufficiency
    (Γ : ChainOfLoops) (hgen : GenericChainOfLoops Γ)
    {d r : ℤ}
    (hrho : 0 ≤ brillNoetherNumber (Γ.g) r d) :
    ExistsDivisorOfDegreeRank Γ d r := by
  ...
```

If full divisor-rank machinery is too large, formalize an intermediate combinatorial surrogate, e.g. a lingering lattice path criterion, and prove equivalence to existence in your model.

A highly respectable formal target is:
```lean
def AdmissibleLatticePath (g : ℕ) (r d : ℤ) : Type := ...
def PathWitnessesDivisor (Γ : ChainOfLoops) (p : AdmissibleLatticePath Γ.g r d) : Prop := ...

theorem generic_chain_of_loops_has_path_iff_rho_nonneg
    (Γ : ChainOfLoops) (hgen : GenericChainOfLoops Γ) {d r : ℤ} :
    (Nonempty (AdmissibleLatticePath Γ.g r d)) ↔
    0 ≤ brillNoetherNumber (Γ.g) r d := by
  ...

theorem path_witness_gives_divisor
    (Γ : ChainOfLoops) (hgen : GenericChainOfLoops Γ)
    {d r : ℤ} (p : AdmissibleLatticePath Γ.g r d)
    (hp : PathWitnessesDivisor Γ p) :
    ExistsDivisorOfDegreeRank Γ d r := by
  ...
```

This route is especially promising because it converts tropical geometry into a discrete combinatorics theorem Lean can manage.

---

### Theorem 4: Bridge to classical algebraic geometry via specialization
This is your cross-domain theorem and should explicitly connect tropical geometry to classical geometry.

Introduce an abstract specialization interface:
```lean
class ClassicalCurve (KCurve : Type _) where
  genus : KCurve → ℕ

class HasClassicalLinearSeries (KCurve : Type _) where
  has_gdr : KCurve → ℤ → ℤ → Prop

class Tropicalization (KCurve TropCurve : Type _)
    [ClassicalCurve KCurve] [TropicalCurve TropCurve] where
  trop : KCurve → TropCurve
  genus_preserved : ∀ X, ClassicalCurve.genus X = TropicalCurve.genus (trop X)
```

Then state and prove an abstract transfer theorem:
```lean
theorem classical_existence_implies_tropical_existence
    {KCurve TropCurve : Type _}
    [ClassicalCurve KCurve] [TropicalCurve TropCurve] [HasDivisorRank TropCurve]
    [HasClassicalLinearSeries KCurve] [Tropicalization KCurve TropCurve]
    (Hspec :
      ∀ X d r, HasClassicalLinearSeries.has_gdr X d r →
        ExistsDivisorOfDegreeRank (Tropicalization.trop X) d r) :
    ∀ X d r, HasClassicalLinearSeries.has_gdr X d r →
      ExistsDivisorOfDegreeRank (Tropicalization.trop X) d r := by
  intro X d r h
  exact Hspec X d r h
```

This alone is too tautological unless enriched. Strengthen it with genus preservation and `ρ`:
```lean
theorem classical_brill_noether_necessary_via_tropical
    {KCurve TropCurve : Type _}
    [ClassicalCurve KCurve] [TropicalCurve TropCurve] [HasDivisorRank TropCurve]
    [HasClassicalLinearSeries KCurve] [Tropicalization KCurve TropCurve]
    (Hspec :
      ∀ X d r, HasClassicalLinearSeries.has_gdr X d r →
        ExistsDivisorOfDegreeRank (Tropicalization.trop X) d r)
    (Hgen :
      ∀ X, BrillNoetherGeneral (Tropicalization.trop X)) :
    ∀ X d r, HasClassicalLinearSeries.has_gdr X d r →
      0 ≤ brillNoetherNumber (ClassicalCurve.genus X) r d := by
  ...
```

This is a meaningful formal schema: classical linear series existence implies the tropical `ρ ≥ 0` obstruction once specialization and genus preservation are installed.

Use `tropical_classical_bridge` explicitly if it already packages part of this implication.

---

## Suggested Lean 4 Type Signatures

These are the exact signatures you should consider implementing or approximating.

```lean
def brillNoetherNumber (g r d : ℤ) : ℤ :=
  g - (r + 1) * (g - d + r)

def brillNoetherNumberNat (g r d : ℕ) : ℤ :=
  (g : ℤ) - ((r : ℤ) + 1) * ((g : ℤ) - (d : ℤ) + (r : ℤ))

theorem brillNoetherNumber_mono_degree
    {g r d₁ d₂ : ℕ} (h : d₁ ≤ d₂) :
    brillNoetherNumberNat g r d₁ ≤ brillNoetherNumberNat g r d₂ := by
  ...

theorem brillNoetherNumber_nonneg_of_degree_large
    {g r d : ℕ} (h : g + r ≤ d) :
    0 ≤ brillNoetherNumberNat g r d := by
  ...

class TropicalCurve (C : Type _) where
  genus : C → ℕ

class HasDivisorRank (C : Type _) where
  Divisor : Type _
  curveOf : Divisor → C
  degree : Divisor → ℤ
  rank : Divisor → ℤ

def ExistsDivisorOfDegreeRank
    {C : Type _} [TropicalCurve C] [HasDivisorRank C]
    (X : C) (d r : ℤ) : Prop :=
  ∃ D : HasDivisorRank.Divisor, HasDivisorRank.curveOf D = X ∧
    HasDivisorRank.degree D = d ∧ HasDivisorRank.rank D ≥ r

class BrillNoetherGeneral
    {C : Type _} [TropicalCurve C] [HasDivisorRank C] (X : C) : Prop where
  rho_nonneg_of_exists :
    ∀ {d r : ℤ}, ExistsDivisorOfDegreeRank X d r →
      0 ≤ brillNoetherNumber (TropicalCurve.genus X) r d

theorem rho_nonneg_of_exists_divisor
    {C : Type _} [TropicalCurve C] [HasDivisorRank C]
    (X : C) [BrillNoetherGeneral X] {d r : ℤ}
    (h : ExistsDivisorOfDegreeRank X d r) :
    0 ≤ brillNoetherNumber (TropicalCurve.genus X) r d := by
  ...

structure ChainOfLoops where
  g : ℕ
  lengths : Fin (2 * g) → ℝ

def GenericChainOfLoops (Γ : ChainOfLoops) : Prop :=
  ∀ i j, i ≠ j → Γ.lengths i ≠ Γ.lengths j

instance : TropicalCurve ChainOfLoops where
  genus := ChainOfLoops.g

theorem chainOfLoops_brill_noether_sufficiency
    (Γ : ChainOfLoops) (hgen : GenericChainOfLoops Γ)
    {d r : ℤ}
    (hrho : 0 ≤ brillNoetherNumber (Γ.g) r d) :
    ExistsDivisorOfDegreeRank Γ d r := by
  ...

class ClassicalCurve (KCurve : Type _) where
  genus : KCurve → ℕ

class HasClassicalLinearSeries (KCurve : Type _) where
  has_gdr : KCurve → ℤ → ℤ → Prop

class Tropicalization (KCurve TropCurve : Type _)
    [ClassicalCurve KCurve] [TropicalCurve TropCurve] where
  trop : KCurve → TropCurve
  genus_preserved : ∀ X, ClassicalCurve.genus X = TropicalCurve.genus (trop X)

theorem classical_brill_noether_necessary_via_tropical
    {KCurve TropCurve : Type _}
    [ClassicalCurve KCurve] [TropicalCurve TropCurve] [HasDivisorRank TropCurve]
    [HasClassicalLinearSeries KCurve] [Tropicalization KCurve TropCurve]
    (Hspec :
      ∀ X d r, HasClassicalLinearSeries.has_gdr X d r →
        ExistsDivisorOfDegreeRank (Tropicalization.trop X) d r)
    (Hgen :
      ∀ X, BrillNoetherGeneral (Tropicalization.trop X)) :
    ∀ X d r, HasClassicalLinearSeries.has_gdr X d r →
      0 ≤ brillNoetherNumber (ClassicalCurve.genus X) r d := by
  ...
```

---

## Proof Strategy Architecture

You must not rely on a single vague proof hint. Use one of the following 3-track architectures.

### Strategy A: Combinatorial tropicalization via lattice paths — most promising
This is the best route if you want a deep theorem with manageable formal content.

1. **Encode generic chains of loops combinatorially**:
   define a discrete witness type for divisor classes, such as lingering lattice paths or chip configurations satisfying local slope constraints.
2. **Prove equivalence between witnesses and divisors of rank `≥ r`**:
   use `rcases` on witness structure, induction on genus `g`, and multi-step `calc` to track degree/rank inequalities.
3. **Show witness existence iff `ρ ≥ 0`**:
   reduce to an integer-combinatorics statement about path dimensions or room inequalities.

Why this is most promising: it transforms hard metric geometry into finite combinatorics, making Lean proofs realistic while retaining genuine mathematical depth.

Key tactics likely needed:
- `induction` on `g`,
- `rcases` on witness/path constructors,
- `by_contra` to derive failure of admissibility from `ρ < 0`,
- `omega`/integer arithmetic lemmas where allowed, but not as the sole content,
- `calc` chains for `ℤ` inequalities.

---

### Strategy B: Abstract axiomatization of Brill–Noether generality + specialization
This route is ideal if the moduli-general theorem is too large but you still want a conceptually major result.

1. **Define `BrillNoetherGeneral X` axiomatically** as the property that divisor existence forces `ρ ≥ 0`.
2. **Instantiate it for a concrete family** such as chains of loops or a graph class already manageable in Lean.
3. **Prove a specialization theorem** from classical curves to tropical curves using `tropical_classical_bridge`, genus preservation, and rank monotonicity.

Why it matters: even if the full combinatorics is deferred, you produce a reusable bridge framework linking tropical and classical Brill–Noether theory.

This is mathematically significant because specialization inequalities are the engine behind modern tropical proofs of classical statements.

---

### Strategy C: Matrix/rank encoding of divisor configurations
This is riskier but potentially revolutionary if you can connect catalog tropical rank results to divisor theory.

1. Encode local chip-firing constraints or linear systems by a tropical matrix/operator.
2. Use `tropical_rank_one_iff_additive_separable` and `tropFactorRank_bound_via_tropical_rank` to control the complexity of these systems.
3. Deduce existence/nonexistence of divisors of prescribed rank from factorization or rank obstructions.

Why this could be field-opening: it would connect Brill–Noether theory with tropical linear algebra and could lead to algorithmic rank certificates.

This is the boldest cross-pollination direction; if it works, it opens a computational approach to tropical moduli.

---

## Cross-Domain Connections You Must Include

At least one theorem must explicitly connect tropical Brill–Noether theory to another field.

### 1. Classical algebraic geometry
This is mandatory. Use specialization/tropicalization to connect `g^r_d` on algebraic curves with divisors on tropical curves.

### 2. Discrete optimization / combinatorics
Chip-firing and divisor rank are fundamentally resource-allocation and reachability problems on graphs. Make this explicit:
- divisors as integer distributions,
- rank as robust feasibility under adversarial subtraction,
- genericity as avoidance of combinatorial degeneracy.

A theorem phrased in this language could be:
```lean
theorem divisor_rank_feasibility_monotone_in_degree
    ...
```
showing a monotonicity principle akin to matroid feasibility.

### 3. Tropical linear algebra / complexity
Use catalog tropical rank results as inspiration for an encoding of linear series existence as a tropical feasibility problem. Even a partial theorem here is valuable:
- “existence of a rank-`r` divisor gives a tropical rank bound on an associated incidence matrix.”

### 4. Physics / statistical mechanics (optional but visionary)
Chip-firing resembles sandpile dynamics. Brill–Noether existence can be interpreted as accessibility of stable states under constrained energy flow on a graph. If you can define an energy functional on divisors and show monotonicity under chip-firing moves, that is an unexpected and exciting bridge.

---

## Concrete Nontrivial Theorems to Aim For

Here are 4 theorem candidates; prove at least 3.

### A. Monotonicity in degree
```lean
theorem exists_divisor_ofDegreeRank_monotone_degree
    {C : Type _} [TropicalCurve C] [HasDivisorRank C]
    (X : C) {d₁ d₂ r : ℤ}
    (h : d₁ ≤ d₂) :
    ExistsDivisorOfDegreeRank X d₁ r →
    ExistsDivisorOfDegreeRank X d₂ r := by
  ...
```
This requires a definition of adding effective chips / degree inflation. If your divisor model supports addition, this is a real theorem, not a tautology.

### B. Necessity of nonnegative `ρ`
```lean
theorem no_general_divisor_when_rho_negative
    {C : Type _} [TropicalCurve C] [HasDivisorRank C]
    (X : C) [BrillNoetherGeneral X] {d r : ℤ}
    (hρ : brillNoetherNumber (TropicalCurve.genus X) r d < 0) :
    ¬ ExistsDivisorOfDegreeRank X d r := by
  intro hE
  have h := rho_nonneg_of_exists_divisor X hE
  linarith
```
This uses `by_contra` or contradiction style and is logically strong.

### C. Family sufficiency for generic chains of loops
```lean
theorem generic_chain_of_loops_brill_noether
    (Γ : ChainOfLoops) (hgen : GenericChainOfLoops Γ) {d r : ℤ} :
    ExistsDivisorOfDegreeRank Γ d r ↔
    0 ≤ brillNoetherNumber (Γ.g) r d := by
  constructor
  · intro h
    exact rho_nonneg_of_exists_divisor Γ h
  · intro hρ
    exact chainOfLoops_brill_noether_sufficiency Γ hgen hρ
```
This is the headline theorem if you can instantiate the necessity side.

### D. Classical–tropical transfer
```lean
theorem classical_gdr_implies_rho_nonnegative
    {KCurve TropCurve : Type _}
    [ClassicalCurve KCurve] [TropicalCurve TropCurve] [HasDivisorRank TropCurve]
    [HasClassicalLinearSeries KCurve] [Tropicalization KCurve TropCurve]
    (Hspec :
      ∀ X d r, HasClassicalLinearSeries.has_gdr X d r →
        ExistsDivisorOfDegreeRank (Tropicalization.trop X) d r)
    (Hgen :
      ∀ X, BrillNoetherGeneral (Tropicalization.trop X)) :
    ∀ X d r, HasClassicalLinearSeries.has_gdr X d r →
      0 ≤ brillNoetherNumber (ClassicalCurve.genus X) r d := by
  intro X d r hgdr
  have hE : ExistsDivisorOfDegreeRank (Tropicalization.trop X) d r := Hspec X d r hgdr
  have hρ := rho_nonneg_of_exists_divisor (Tropicalization.trop X) hE
  simpa [Tropicalization.genus_preserved X] using hρ
```

This is a real bridge theorem, not merely a translation.

---

## How to Use Existing Verified Theorems

Do not cite catalog items decoratively. Use them structurally.

- `tropical_classical_bridge`:
  inspect its exact statement and use it to instantiate or simplify the specialization theorem above. If it already relates tropical and classical semantics, repurpose that architecture for divisor-existence transport.
- `tropical_rational_eq_iff_crossmul`:
  useful if divisor classes or piecewise-linear functions are encoded via tropical rationals and you need equality criteria without brittle normalization.
- `tropical_rank_one_iff_additive_separable`:
  if you encode rank-one tropical linear series data, use this to characterize decomposable local sections or slope tables.
- `tropFactorRank_bound_via_tropical_rank`:
  if divisor-search is encoded by tropical matrices, this gives upper bounds and can become a nonexistence certificate.
- `tropical_formula_iff_recognizable_and_deriv_closed`:
  potentially useful if you define a recognizable language of admissible lattice paths or chip-firing words; this is speculative but could produce a surprising automata-theoretic reformulation of Brill–Noether admissibility.

That last point is especially visionary: admissible divisor evolution on a chain of loops may be representable as a recognizable tropical language. If you can prove this, you create a bridge between tropical geometry and automata theory.

---

## Application Keywords

Include these explicitly in comments/docstrings or theorem descriptions so the project is discoverable:

- tropical Brill–Noether
- metric graphs
- chip-firing
- divisor rank
- linear series
- chain of loops
- generic tropical curve
- specialization
- algebraic curves
- moduli of curves
- tropical linear algebra
- combinatorial geometry
- sandpile dynamics
- discrete optimization
- certified nonexistence
- tropicalization

---

## Conjecture With Testable Prediction

You must state at least one falsifiable conjecture with a clear computational test.

### Conjecture 1: Generic chain witness count polynomiality
For fixed `g, r`, the number of combinatorial witnesses for degree `d` on a generic chain of loops is eventually polynomial in `d`, with degree equal to `ρ(g,r,d)` in the nonnegative regime.

Possible Lean-facing declaration:
```lean
conjecture witness_count_eventually_polynomial :
  ∀ g r : ℕ, ∃ P : Polynomial ℚ, ∃ N : ℕ,
    ∀ d ≥ N,
      witnessCount g r d = P.eval (d : ℚ)
```

**Computational test**: enumerate admissible lattice paths for small `g,r,d`, fit candidate polynomials, and search for counterexamples at larger `d`.

### Conjecture 2: Tropical rank certificate for divisor existence
There exists a canonically associated tropical matrix `M(Γ,d,r)` such that for generic `Γ`,
\[
\text{ExistsDivisorOfDegreeRank } \Gamma\, d\, r
\iff \operatorname{tropicalRank}(M(\Gamma,d,r)) \ge r+1.
\]

**Computational test**: build `M(Γ,d,r)` for random generic chains of loops of small genus and compare tropical rank against brute-force divisor search.

### Conjecture 3: Recognizability of admissible divisor languages
The set of chip-firing words producing rank-`≥ r` divisors on a generic chain of loops is a recognizable tropical language.

**Computational test**: generate chip-firing traces, infer automata, and check closure properties predicted by `tropical_formula_iff_recognizable_and_deriv_closed`.

Pick at least one and include it formally in `FUTURE_DIRECTIONS.md`.

---

## Deliverables

1. A Lean file containing:
   - at least one new definition,
   - at least 3 substantial theorems,
   - proofs using induction / `rcases` / contradiction / arithmetic `calc`,
   - no trivial enumeration proofs.

2. A structured `FUTURE_DIRECTIONS.md` with **3–5 falsifiable hypotheses**, each including:
   - precise conjecture,
   - what data/computation would test it,
   - what outcome would refute it,
   - what theorem would become plausible if it survives testing.

Required themes for those hypotheses:
- one about generic chains of loops,
- one about classical specialization,
- one about tropical linear algebra or automata recognition.

---

## Final Tactical Advice

If full tropical divisor theory on arbitrary metric graphs is too large, do **not** retreat to toy lemmas. Instead:
- formalize the Brill–Noether arithmetic cleanly,
- define a robust abstract interface for tropical curves and divisor rank,
- prove the necessity theorem abstractly,
- prove sufficiency on a deep explicit family (generic chains of loops),
- and connect the whole system to classical geometry via specialization.

That package would already be a field-opening Lean foundation: a certified tropical Brill–Noether core from which divisor algorithms, tropical Petri, and moduli-theoretic computations can grow.

### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Tropical
Research mode: prove
