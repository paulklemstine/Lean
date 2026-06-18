
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Consciousness as Integrated Information: Mathematical Foundations
**Domain**: Applications
**Mathematical framing**: Formalize Tononi's Integrated Information Theory (IIT) as a rigorous mathematical framework. Prove that the maximum integrated information Phi of a system is the minimum information partition. Show that Phi is NP-hard to compute and construct polynomial-time approximations.
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/BerggrenFactoring.lean
import Mathlib

/-! # Berggren Tree and Integer Factoring

The Berggren tree enumerates all primitive Pythagorean triples via three
matrix transformations. This structure can be exploited for integer factoring.

## Research Direction 3.4: Berggren Tree Factoring Algorithms
-/

/-- A Pythagorean triple -/
def IsPythTriple' (a b c : ℤ) : Prop := a^2 + b^2 = c^2

/-- The base triple (3, 4, 5) is Pythagorean -/
theorem base_triple_pyth : IsPythTriple' 3 4 5 := by unfold IsPythTriple'; norm_num

/-- Pythagorean triples are symmetric in a, b -/
theorem pyth_triple_symm {a b c : ℤ} (h : IsPythTriple' a b c) :
    IsPythTriple' b a c := by unfold IsPythTriple' at *; linarith

/-- Scaling preserves Pythagorean triples -/
theorem pyth_triple_scale {a b c : ℤ} (h : IsPythTriple' a b c) (k : ℤ) :
    IsPythTriple' (k * a) (k * b) (k * c) := by
  unfold IsPythTriple' at *; ring_nf; nlinarith [sq_nonneg k]

/-- If d divides both a and b, then d² divides a² + b² -/
theorem sum_two_squares_gcd (a b d : ℤ) (hd : d ∣ a) (hd2 : d ∣ b) :
    d^2 ∣ a^2 + b^2 := by
  obtain ⟨x, rfl⟩ := hd; obtain ⟨y, rfl⟩ := hd2; exact ⟨x^2 + y^2, by ring⟩

/-- Fermat's factoring via difference of squares -/
theorem fermat_factor (n a b : ℤ) (h : n = a^2 - b^2) :
    n = (a - b) * (a + b) := by rw [h]; ring

/-- Connection to factoring: nontrivial GCD gives a factor -/
theorem pyth_factor_connection (n a : ℕ) (_hn : 1 < n) (ha : 1 < Nat.gcd a n)
    (ha2 : Nat.gcd a n < n) : ∃ d, 1 < d ∧ d < n ∧ d ∣ n :=
  ⟨Nat.gcd a n, ha, ha2, Nat.gcd_dvd_right a n⟩

/-- The Lorentz form characterizes Pythagorean triples -/
def lorentzForm (a b c : ℤ) : ℤ := c^2 - a^2 - b^2

theorem pyth_iff_lorentz (a b c : ℤ) :
    IsPythTriple' a b c ↔ lorentzForm a b c = 0 := by
  unfold IsPythTriple' lorentzForm; constructor <;> intro h <;> linarith

/-- Berggren matrix A preserves Pythagorean property -/
theorem berggren_A_preserves (a b c : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) := by
  unfold IsPythTriple' at *; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

/-- Berggren matrix B preserves Pythagorean property -/
theorem berggren_B_preserves (a b c : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) := by
  unfold IsPythTriple' at *; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

/-- Berggren matrix C preserves Pythagorean property -/
theorem berggren_C_preserves (a b c : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) := by
  unfold IsPythTriple' at *; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

/-- Hypotenuse grows under Berggren B -/
theorem berggren_B_hyp_growth (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) : c < 2*a + 2*b + 3*c := by linarith

/-- Primitive triple: coprime legs -/
def IsPrimitivePythTriple' (a b c : ℕ) : Prop :=
  IsPythTriple' (a : ℤ) (b : ℤ) (c : ℤ) ∧ Nat.Coprime a b

/-- The base triple (3, 4, 5) is primitive -/
theorem base_triple_primitive : IsPrimitivePythTriple' 3 4 5 :=
  ⟨base_triple_pyth, by decide⟩


-- NEW_FILE: Catalog/Bridges/ClosureNucleusDuality.lean
/-
# Closure–Nucleus Spectral Duality via Idempotent Semimodules

This file formalizes a finite duality theorem at the interface of closure systems,
idempotent algebra, and algebraic logic. The core result shows that closure-theoretic
data equipped with a logical nucleus can be represented exactly by evaluation on
join-prime spectral points, and that this representation supports certified
reconstruction of closure operators and sound-and-complete Kripke-style semantics.

## Main Results

* `closure_subset_of_closed_superset` — Closure containment from superset closure.
* `implication_valid_iff_all_prime_points` — Completeness: x ∈ cl(A) ↔ all primes
  containing A contain x.
* `closure_equals_sInter_of_prime_points` — Closure reconstruction from prime
  intersection.
* `spectral_eval_injective` — Injectivity of the spectral evaluation map under
  separation.
* `finite_closure_nucleus_spectral_embedding` — Bijection between closed sets
  and spectral observables.
* `certified_closure_reconstruction` — Certified recovery of the closure operator
  from spectral data.
* `implication_semantics_complete` — Sound-and-complete finite Kripke semantics.
* `implicational_basis_reconstruction` — Finite implicational basis generation.
* `nucleus_fixed_fragment_characterization` — Reconstruction of the nucleus-fixed
  fragment from nucleus-stable primes.

Keywords: spectral duality, closure systems, nuclei, idempotent semimodules,
Horn logic, implicational bases, Kripke semantics, formal concept analysis,
certified reconstruction, finite Stone duality.
-/

import Mathlib

open Set Function

namespace ClosureNucleusDuality

/-! ## Section 1: Core Definitions -/

/-- A set is closed under a closure operator when it is a fixed point. -/
def IsClosed (cl : Set α → Set α) (s : Set α) : Prop := cl s = s

/-- A closure operator is extensive, monotone, and idempotent. -/
structure IsClosureOperator (cl : Set α → Set α) : Prop where
  extensive : ∀ s, s ⊆ cl s
  mono : Monotone cl
  idempotent : ∀ s, cl (cl s) = cl s

/-- A finite closure-nucleus system: a closure operator on a finite type
    equipped with a nucleus on the closed-set semilattice. -/
structure FiniteClosureNucleus (α : Type*) [Fintype α] [DecidableEq α] where
  cl : Set α → Set α
  isClosure : IsClosureOperator cl
  nuc : Set α → Set α
  nuc_closed : ∀ s, IsClosed cl s → IsClosed cl (nuc s)
  nuc_mono : Monotone nuc
  nuc_idem : ∀ s, nuc (nuc s) = nuc s
  nuc_extensive_on_closed : ∀ s, IsClosed cl s → s ⊆ nuc s

/-- A join-prime closed set stable under the nucleus: closed, nucleus-fixed,
    and nonempty. -/
structure JoinPrimeClosed (cl : Set α → Set α) (nuc : Set α → Set α) (p : Set α) : Prop where
  closed : IsClosed cl p
  nuc_stable : nuc p = p
  nonempty : p.Nonempty

/-! ## Section 2: Basic Properties of Closure Operators -/

variable {α : Type*}

/-- The image of a closure operator is always closed. -/
theorem cl_is_closed (cl : Set α → Set α) (hcl : IsClosureOperator cl) (s : Set α) :
    IsClosed cl (cl s) :=
  hcl.idempotent s

/-- If s ⊆ t and t is closed, then cl(s) ⊆ t. -/
theorem closure_subset_of_closed_superset (cl : Set α → Set α) (hcl : IsClosureOperator cl)
    (s t : Set α) (ht : IsClosed cl t) (hst : s ⊆ t) : cl s ⊆ t := by
  have h1 : cl s ⊆ cl t := hcl.mono hst
  rw [show cl t = t from ht] at h1
  exact h1

/-- The closure of a set is the smallest closed set containing it. -/
theorem closure_is_smallest_closed (cl : Set α → Set α) (hcl : IsClosureOperator cl)
    (s : Set α) : cl s = ⋂₀ {t | IsClosed cl t ∧ s ⊆ t} := by
  ext x; simp only [mem_sInter, mem_setOf_eq]; constructor
  · intro hx t ⟨htcl, hst⟩
    exact closure_subset_of_closed_superset cl hcl s t htcl hst hx
  · intro hx
    exact hx (cl s) ⟨cl_is_closed cl hcl s, hcl.extensive s⟩

/-! ## Section 3: Separation and Spectral Completeness -/

/-- The prime separation condition: for every closed set s and element x ∉ s,
    there exists a join-prime stable closed set containing s but not x.
    This is the "enough points" condition for finite spectral duality. -/
def PrimeSeparation (cl : Set α → Set α) (nuc : Set α → Set α) : Prop :=
  ∀ (s : Set α) (x : α), IsClosed cl s → x ∉ s →
    ∃ p, JoinPrimeClosed cl nuc p ∧ s ⊆ p ∧ x ∉ p

/-- **Core completeness theorem**: Under prime separation, membership in a closure
    is equivalent to membership in all prime points containing the premise.
    This is the logical completeness statement:
    `x ∈ cl(A) ↔ ∀ prime p, A ⊆ p → x ∈ p`. -/
theorem implication_valid_iff_all_prime_points
    (cl : Set α → Set α) (nuc : Set α → Set α)
    (hcl : IsClosureOperator cl)
    (hsep : PrimeSeparation cl nuc)
    (A : Set α) (x : α) :
    x ∈ cl A ↔ ∀ p, JoinPrimeClosed cl nuc p → A ⊆ p → x ∈ p := by
  constructor
  · intro hx p hp hA
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Mathematical Foundations of Integrated Information

The file `IntegratedInformation.lean` formalizes the combinatorial skeleton of
Tononi's Integrated Information Theory (IIT): a finite `System` carries an
effective-information functional `ei` over nontrivial bipartitions (`parts`), and
the integrated information `Φ` is the value at the Minimum Information Partition.
We proved that the MIP exists and realizes `Φ` (`exists_MIP`), that `Φ` is the
greatest lower bound of the landscape (`phi_le_ei`, `le_phi`), that `Φ ≥ 0`
(`phi_nonneg`), the reducibility dichotomy `Φ = 0 ↔ ∃` a zero cut
(`phi_eq_zero_iff`), and a monotonicity principle (`phi_mono`). The following
directions extend this scaffold toward the harder claims of IIT.

## 1. Full partition lattice, not just bipartitions

Our `parts n` ranges over bipartitions (a subset and its complement). Real IIT
quotients over the full lattice of set partitions of the elements, and `Φ` is the
infimum of the partition-distance over *all* partitions, normalized by partition
size. Conjecture: defining `partsFull n` as `Finset.univ`-indexed
`Setoid`/partition objects, the bipartition `Φ` is an *upper bound* for the
full-lattice `Φ`, with equality exactly when the minimizing partition is binary.

**The key insight is** that the partition lattice is graded by block count, and
the effective-information functional is supermodular along refinement, so the
minimizer can be searched block-count by block-count rather than over the
super-exponential lattice at once. **Why now?** Mathlib's `Finpartition` API and
its order structure (`Finpartition.instLattice`) are now mature enough to host
`ei : Finpartition (univ : Finset (Fin n)) → ℝ` and the `min'` machinery we
already use transfers verbatim.

## 2. NP-hardness of computing Φ via a Karp reduction to MIN-BISECTION

The concept brief asks to show `Φ` is NP-hard to compute. The honest formal route
is a Karp reduction: encode an instance of weighted graph MIN-BISECTION as an IIT
`System` whose `ei` on a cut `A` equals the cut-weight `w(A, Aᶜ)`, so that the MIP
*is* the minimum bisection and `Φ` *is* its weight. Conjecture: there is a
polynomial-time computable map `g : Graph → System` with
`Φ (g G) = minBisection G`, witnessed inside Mathlib's
`Computability`/`Polynomial`-time reduction framework.

**The key insight is** that `phi_eq_zero_iff` already shows `Φ` decides a
combinatorial existence question ("is there a balanced zero cut?"), which is the
decision-problem shadow of an NP-complete bisection question — so the reduction
target is structurally identical to what we proved. **Why now?** With
`exists_MIP` pinning `Φ` to an explicit argmin, the reduction reduces to proving a
single arithmetic identity `ei A = cutWeight A`, isolating the hardness in a
clean, checkable lemma rather than in the optimization itself.

## 3. A provable polynomial-time approximation with a multiplicative guarantee

Construct a poly-time computable `ΦApprox : System → 
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
