
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
    {
      "name": "descriptive_name",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
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

**Title**: Close Proofs: Formalized framework connecting Collatz dynami
**Domain**: Novelty
**Mathematical framing**: Cycle f2700283 (Q=0.426) proved 1066 theorems in Applications but left 1 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions

## Synthesis

This research cycle established a formalized framework connecting Collatz dynamics to proof-theoretic barriers. The central insight is that three structural gaps — t
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/Goldbach/Defs.lean
/-
Copyright (c) 2025. All rights reserved.
Formal additive prime decomposition framework: definitions.
-/
import Mathlib

/-!
# Additive Prime Decomposition Framework: Core Definitions

This file defines the core concepts for a certified additive prime decomposition
framework. The key abstractions are:

* `TwoPrimeRepresentable` — a number is a sum of two primes
* `ThreePrimeRepresentable` — a number is a sum of three primes
* `GoldbachUpTo` — binary Goldbach conjecture holds up to a bound
* `AdditiveBasisCertificate` — a certificate structure for verified decompositions
* `RepresentsAsSumFrom` — general k-fold additive representation from a set
* `goldbachPairsUpTo` / `CoveredEvens` — graph-theoretic covering reformulation
* `findGoldbachPair` — verified search algorithm

## Design Philosophy

The framework separates structural/parity obstructions from computational
verification. Certificates are first-class objects that can be independently
generated and verified, enabling modular extension of verified ranges.
-/

open Finset Nat

namespace AdditiveGoldbach

/-! ## Core representation predicates -/

/-- A natural number is two-prime representable if it equals a sum of two primes. -/
def TwoPrimeRepresentable (n : ℕ) : Prop :=
  ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n

/-- A natural number is three-prime representable if it equals a sum of three primes. -/
def ThreePrimeRepresentable (n : ℕ) : Prop :=
  ∃ p q r : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ Nat.Prime r ∧ p + q + r = n

/-- Binary Goldbach holds up to N: every even n with 4 ≤ n ≤ N is two-prime representable. -/
def GoldbachUpTo (N : ℕ) : Prop :=
  ∀ n, 4 ≤ n → n ≤ N → Even n → TwoPrimeRepresentable n

/-- General k-fold additive representation from a set. -/
def RepresentsAsSumFrom (s : Set ℕ) (k : ℕ) (n : ℕ) : Prop :=
  ∃ f : Fin k → ℕ, (∀ i, f i ∈ s) ∧ (∑ i, f i) = n

/-! ## Certificate structure -/

/-- An `AdditiveBasisCertificate` packages a witness function together with
soundness proofs. Given such a certificate, one can extract verified prime-pair
decompositions for any number in its domain. -/
structure AdditiveBasisCertificate where
  /-- The carrier set of primes used -/
  carrier : Finset ℕ
  /-- Witness function: given n, optionally returns a prime pair (p, q) with p + q = n -/
  witness : ℕ → Option (ℕ × ℕ)
  /-- Left component of any witness is prime -/
  sound_prime_left : ∀ n p q, witness n = some (p, q) → Nat.Prime p
  /-- Right component of any witness is prime -/
  sound_prime_right : ∀ n p q, witness n = some (p, q) → Nat.Prime q
  /-- Witness pair sums to n -/
  sound_sum : ∀ n p q, witness n = some (p, q) → p + q = n

/-! ## Verified search algorithm -/

/-- Search for a Goldbach pair by iterating over candidate primes.
    For even n, searches for p from 2 upward such that both p and n-p are prime. -/
def findGoldbachPairAux (n : ℕ) (fuel : ℕ) (k : ℕ) : Option (ℕ × ℕ) :=
  match fuel with
  | 0 => none
  | fuel + 1 =>
    if k > n then none
    else if decide (Nat.Prime k) then
      if decide (Nat.Prime (n - k)) then
        if k + (n - k) == n then some (k, n - k)
        else findGoldbachPairAux n fuel (k + 1)
      else findGoldbachPairAux n fuel (k + 1)
    else findGoldbachPairAux n fuel (k + 1)

/-- Find a Goldbach pair for n by searching from p = 2 upward. -/
def findGoldbachPair (n : ℕ) : Option (ℕ × ℕ) :=
  findGoldbachPairAux n n 2

/-! ## Graph-theoretic covering reformulation -/

/-- The set of primes below N+1, as a Finset. -/
def primesBelow (N : ℕ) : Finset ℕ :=
  (Finset.range (N + 1)).filter Nat.Prime

/-- All ordered pairs of primes whose sum is at most N. -/
def goldbachPairsUpTo (N : ℕ) : Finset (ℕ × ℕ) :=
  ((primesBelow N).product (primesBelow N)).filter (fun pq => pq.1 + pq.2 ≤ N)

/-- The set of even numbers covered by prime-pair sums up to N. -/
def CoveredEvens (N : ℕ) : Set ℕ :=
  {n | ∃ p q, (p, q) ∈ goldbachPairsUpTo N ∧ p + q = n}

/-! ## Least Goldbach prime (for conjectures) -/

/-- The least prime p such that n - p is also prime, if one exists. -/
def leastGoldbachPrime (n : ℕ) : Option ℕ :=
  match findGoldbachPair n with
  | some (p, _) => some p
  | none => none

/-! ## Decidability instances -/

instance (n : ℕ) : Decidable (TwoPrimeRepresentable n) :=
  decidable_of_iff
    (∃ p ∈ Finset.range (n + 1), ∃ q ∈ Finset.range (n + 1),
      Nat.Prime p ∧ Nat.Prime q ∧ p + q = n)
    ⟨fun ⟨p, _, q, _, hp, hq, hpq⟩ => ⟨p, q, hp, hq, hpq⟩,
     fun ⟨p, q, hp, hq, hpq⟩ => ⟨p, Finset.mem_range.mpr (by omega),
      q, Finset.mem_range.mpr (by omega), hp, hq, hpq⟩⟩

end AdditiveGoldbach


-- NEW_FILE: Catalog/Algebra/Hadamard/Paley.lean
/-
  # Skew Conference Matrices and the Paley Construction Core

  This file formalizes the algebraic heart of the **Paley I construction** for
  Hadamard matrices: the order-preserving passage between *skew conference
  matrices* and *skew-Hadamard matrices*.

  A skew conference matrix `C` of order `n` has zero diagonal, ±1 off-diagonal
  entries, satisfies `Cᵀ = -C`, and the conference identity `C Cᵀ = (n-1) I`.
  The Jacobsthal (quadratic residue) matrix over `GF(q)` for `q ≡ 3 (mod 4)` is
  the canonical example; this file isolates the construction step that turns such
  a `C` into a genuine Hadamard matrix `I + C`, *without* yet building the
  quadratic-residue matrix itself.

  Main results:
  * `skewConference_mulSelf`                  — `C * C = (1 - n) • I`  (algebraic core)
  * `skewConference_add_one_isSkewHadamard`   — `I + C` is skew-Hadamard
  * `skewConference_hadamardOrder`            — a skew conference matrix of order
                                                `n` yields a Hadamard order `n`
  * `isSkewHadamard_sub_one_skewConference`   — the converse: `H - I` recovers a
                                                skew conference matrix

  These extend the catalog's Hadamard development (`IsHadamard'`,
  `HadamardOrder'`, `hadamardOrder'_mul`, the Sylvester family in
  `Algebra/Hadamard/Constructions.lean`) by adding the first construction
  yielding orders that are NOT forced to be powers of two: skew conference
  matrices exist e.g. for every `n = q + 1` with `q ≡ 3 (mod 4)` prime power.

  All predicates are redefined self-containedly (matching the catalog's
  `IsHadamard'` verbatim) so the file compiles against `import Mathlib` alone,
  consistent with every other file in `Algebra/Hadamard/`.
-/
import Mathlib

open Matrix Finset BigOperators

/-! ## Core predicates (self-contained; `IsHadamardP` matches catalog `IsHadamard'`) -/

/-- A matrix is Hadamard if all entries are ±1 and `H * Hᵀ = n • I`.
    Identical to the catalog's `IsHadamard'` / `IsHadamard`. -/
def IsHadamardP {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  (∀ i j, H i j = 1 ∨ H i j = -1) ∧
  H * H.transpose = (n : ℤ) • (1 : Matrix (Fin n) (Fin n) ℤ)

/-- An order `n` admits a Hadamard matrix (matches catalog `HadamardOrder'`). -/
def HadamardOrderP (n : ℕ) : Prop :=
  ∃ H : Matrix (Fin n) (Fin n) ℤ, IsHadamardP H

/-- A **skew conference matrix** of order `n`: zero diagonal, ±1 off the
    diagonal, antisymmetric (`Cᵀ = -C`), and satisfying the conference identity
    `C Cᵀ = (n - 1) • I`. -/
def IsSkewConference {n : ℕ} (C : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  (∀ i, C i i = 0) ∧
  (∀ i j, i ≠ j → C i j = 1 ∨ C i j = -1) ∧
  C.transpose = -C ∧
  C * C.transpose = ((n : ℤ) - 1) • (1 : Matrix (Fin n) (Fin n) ℤ)

/-- A **skew-Hadamard matrix**: a Hadamard matrix `H` whose "skew part" is
    trivial, i.e. `H + Hᵀ = 2 • I`. Equivalently `H - I` is antisymmetric. -/
def IsSkewHadamardP {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  IsHadamardP H ∧ H + H.transpose = (2 : ℤ) • (1 : Matrix (Fin n) (Fin n) ℤ)

/-! ## Algebraic core -/

-- !-- Lab Notebook: skewConference_mulSelf -- !--
-- !-- Hypothesis: antisymmetry + the conference identity should pin down C*C exactly -- !--
-- !-- Result: C*C = (1-n)•I, obtained by substituting Cᵀ = -C into C*Cᵀ = (n-1)
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Collatz Reachability and Proof-Theoretic Barriers

The file `Catalog/Logic/CollatzOddReduction.lean` lifts the pointwise structural
results of `Logic.CollatzModularDynamics` (powers of two, fixed points, short
cycles) to the global *reachability* relation `Reaches n := ∃ k, C^[k] n = 1`, and
proves a clean structural reduction: the Collatz conjecture is **equivalent** to
its restriction to odd positive integers (`collatz_iff_odd`), powered by the
doubling-invariance lemma `reaches_double`. The following conjectures extend this
reachability framework. Each is stated to be testable and falsifiable: either a
formal Lean proof closes it, or a single explicit numeric counterexample refutes
it.

## 1. The 2-adic seed reduction is sharp: residue-2 reduction fails

**Conjecture.** There is *no* analogue of `reaches_double` modulo 3, i.e. the
statement "`Reaches (3 * n) ↔ Reaches n` for all `n`" is **false**, and a small
explicit `n` witnesses the failure of the forward implication's naive proof.

The key insight is that doubling invariance is special: it works only because
`C (2*n) = n` is an *exact* one-step retraction, whereas multiplication by 3 lands
on an odd number whose first Collatz step *expands* rather than contracts. Probing
which arithmetic operations admit a `reaches_*` invariance lemma isolates exactly
the structural feature (a contracting retraction `C ∘ op = id`) that the reduction
exploits.

**Why now?** We already have `C_two_mul : C (2 * n) = n` as the lone algebraic
identity behind the entire reduction; testing its non-existence for other
multipliers is a direct, mechanical extension that pins down the boundary of the
method, and is decidable by `#eval` search for any candidate counterexample.

## 2. Bounded-stopping reachability is decidable and monotone

**Conjecture.** Define `ReachesIn b n := ∃ k ≤ b, (C^[k]) n = 1`. Then for every
bound `b`, the predicate `ReachesIn b` is `Decidable`, and the doubling lemma
refines quantitatively to `ReachesIn (b+1) (2*n) ↔ ReachesIn b n` for `n > 0`.

The key insight is that `reaches_double` actually carries a *step-count*: doubling
costs exactly one extra Collatz step, so the existential bound shifts by one. This
upgrades the qualitative equivalence to an exact arithmetic relation between
stopping times of `n` and `2n`.

**Why now?** Our proof of `reaches_double` already produces the witness `k+1` from
`k` explicitly (via `Function.iterate_succ_apply`), so the step-counting version is
a quantitative annotation of a proof we have in hand, and decidability follows from
bounded search.

## 3. Total stopping time of odd seeds dominates the conjecture's complexity

**Conjecture.** Let `T n` be the least `k` with `(C^[k]) n = 1` (defined when
`Reaches n`). Then `T (2*n) = T n + 1` for `n > 0`, and consequently the supremum
of `T` over any interval `[1, N]` is attained at an *odd* number once `N ≥ 2`.

The key insight is that even inputs are never "harder" than their odd halves: 
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
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a name, a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
