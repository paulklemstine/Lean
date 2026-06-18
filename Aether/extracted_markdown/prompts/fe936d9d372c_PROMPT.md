
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
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
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

**Title**: Close Proofs: The file `Catalog/Geometry/IsingStereoRG.lean` establishes the first r
**Domain**: Novelty
**Mathematical framing**: Cycle 257f7c90 (Q=0.470) proved 788 theorems in Geometry but left 3 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: Inverse Stereographic Renormalization Group

The file `Catalog/Geometry/IsingStereoRG.lean` establishes the first rigorous, machine-checked
bridge between renormalization-group (R
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/ClassicalGroupExpanders.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Certified Expanders for Classical Groups

This file develops a certificate-based framework for constructing expander
Cayley graphs from finite classical groups (symplectic, orthogonal, unitary).
The central innovation is a **certificate architecture** that connects:

1. Regular toral elements (algebraic structure in the group)
2. Invariant-subspace-breaking conditions (linear algebra)
3. Spectral expansion of resulting Cayley graphs (graph theory)

## Main definitions

* `IsRegularToral`: A linear map whose minimal polynomial equals its
  characteristic polynomial — the finite-field shadow of a regular
  semisimple element in a reductive group.
* `BreaksAllInvariantSubspaces`: A second element that maps some vector
  of every proper nontrivial invariant subspace of the first element outside it.
* `ClassicalGenCertificate`: The bundled certificate combining regularity
  and invariance-breaking, providing a checkable criterion for generation.
* `HasVertexExpansion`: The Cayley graph expansion property that
  every small set has large vertex boundary.
* `CayleyNeighborFinset`: The neighbor set of a subset under a generating set
  in a Cayley graph.

## Main results

* `classical_certificate_no_proper_invariant_submodule`: If `(s, t)` satisfy
  the classical certificate with `s` having irreducible characteristic
  polynomial, then no proper nontrivial submodule is invariant under
  every element of `⟨s, t⟩`.
* `vertex_expansion_implies_generates`: A finite group with a vertically
  expanding generating set must be generated by that set (expansion
  forces connectivity).
* `expansion_monotone_of_superset`: Adding generators preserves expansion
  (monotonicity of vertex expansion under generating-set enlargement).
* `cayley_neighbor_card_le`: Upper bound on neighborhood size.

## Strategy

The proof of the main structural theorem proceeds by:
1. Observing that any `⟨s,t⟩`-invariant subspace is in particular `s`-invariant.
2. Applying the irreducible characteristic polynomial theorem
   (`eq_bot_or_top_of_charpoly_irreducible` from MatrixGroupGeneration)
   to conclude `s`-invariant subspaces are `⊥` or `⊤`.
3. Combining with the invariance-breaking certificate to exclude `⊤`.

The expansion theorems use direct combinatorial arguments about
Cayley graphs in finite groups.

## References

* Helfgott, H. (2008). Growth and generation in SL_2(ℤ/pℤ).
* Kassabov, M., Lubotzky, A., Nikolov, N. (2006). Finite simple groups
  as expanders.
* Babai, L., Kantor, W.M., Lubotzky, A. (1989). Small-diameter Cayley
  graphs for finite simple groups.
* Gowers, W.T. (2008). Quasirandom groups.
-/

import Mathlib

open Polynomial Submodule LinearMap Finset

/-! ## Section 1: Regular Toral Elements -/

/-- An endomorphism is **regular toral** if its minimal polynomial equals its
characteristic polynomial. Over a finite field, this means the element
is regular semisimple — its centralizer is a maximal torus.

This is the finite-field shadow of the algebraic-geometry concept of a
regular semisimple element in a reductive group, which lies on a unique
maximal torus and has the smallest possible centralizer dimension. -/
def IsRegularToral {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V] (φ : Module.End K V) : Prop :=
  minpoly K φ = φ.charpoly

/-- A regular toral element with irreducible characteristic polynomial
has no proper nontrivial invariant subspace. This strengthens the base
regularity condition with an algebraic irreducibility hypothesis that
is computationally checkable. -/
def IsStronglyRegularToral {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V] (φ : Module.End K V) : Prop :=
  IsRegularToral φ ∧ Irreducible φ.charpoly

/-! ## Section 2: Invariance-Breaking Certificate -/

/-- `BreaksAllInvariantSubspaces φ ψ` says that `ψ` maps some element out of
every proper nontrivial `φ`-invariant submodule. This is the second half
of the generation certificate: it ensures that the pair `(φ, ψ)` cannot
be simultaneously block-triangularized.

Concretely, for each proper nontrivial `φ`-stable subspace `W`, there
exists `w ∈ W` such that `ψ(w) ∉ W`. -/
def BreaksAllInvariantSubspaces {K V : Type*} [Field K] [AddCommGroup V]
    [Module K V] (φ ψ : Module.End K V) : Prop :=
  ∀ W : Submodule K V, W ≠ ⊥ → W ≠ ⊤ →
    (∀ w, w ∈ W → φ w ∈ W) →
    ∃ w, w ∈ W ∧ ψ w ∉ W

/-- The **classical generation certificate** for a pair of endomorphisms
`(s, t)` acting on a module `V`. The certificate combines:

1. **Regularity**: `s` is strongly regular toral (irreducible charpoly,
   so its invariant subspaces are exactly `⊥` and `⊤`).
2. **Breaking**: `t` breaks all proper nontrivial `s`-invariant subspaces.

When both conditions hold, the subgroup generated by `s` and `t` acts
irreducibly on `V`, which is the key structural input for generation
arguments in finite classical groups.

Note: For strongly regular toral `s`, condition 2 is automatically
satisfied (there are no proper nontrivial `s`-invariant subspaces),
so the certificate is really about the combined algebraic structure.
The real power emerges when we relax to the non-irreducible case
in future work. -/
structure ClassicalGenCertificate
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V]
    (s t : Module.End K V) : Prop where
  /-- The first generator has irreducible characteristic polynomial -/
  s_charpoly_irred : Irreducible s.charpoly
  /-- The second generator breaks all proper invariant subspaces of `s` -/
  t_breaks : BreaksAllInvariantSubspaces s t

/-! ## Section 3: Cayley Graph Expansion -/

/-- The **Cayley neighbor set** of a subset `A ⊆ G` under a generating set `S`:
the set of all elements of the form `a * s` where `a ∈ A` and `s ∈ S`.
This is the set of vertices reachable in one step from `A` in the
right Cayley graph `Cay(G, S)`. -/
def CayleyNeighborFinset {G : Type*} [DecidableEq G] [Group G] [Fintype G]
    (S : Finset G) (A : Finset G) : Finset G :=
  Finset.biUnion A (fun a => S.image (fun s => a * s))

/-- The **vertex boundary** of `A` under `S`: elements in the Cayley
neighborhood of `A` that are not in `A` itself. These are the "new"
vertices discovered by one step of the random walk from `A`. -/
def CayleyVertexBoundary {G : Type*} [DecidableEq G] [Group G] [Fintype G]
    (S : Finset G) (A : Finset G) : Finset G :=
  CayleyNeighborFinset S A \ A

/-- A finite group `G` with generating set `S` has **vertex expansion** `ε`
if every nonempty subset `A` with `|A| ≤ |G|/2` has vertex boundary
of size at least `ε * |A|`.

This is the combinatorial manifestation of spectral gap: a Cayley graph
with second eigenvalue at most `1 - ε` satisfies vertex expansion with
a constant depending on `ε`. -/
def HasVertexExpansion {G : Type*} [DecidableEq G] [Group G] [Fintype G]
    (S : Finset G) (ε : ℝ) : Prop :=
  ε > 0 ∧
  ∀ A : Finset G,
    A.Nonempty →
    2 * A.card ≤ Fintype.card G →
    ε * A.card ≤ (CayleyVertexBoundary S A).card

/-- The **certified spectral gap** property: the normalized averaging
operator on the Cayley graph has second-largest eigenvalue at most `1 - ε`.
We define this abstractly as the combination of vertex expansion and
generation, which are the key consequences of spectral gap. -/
def HasCertifiedGap {G : Type*} [DecidableEq G] [Group G] [Fintype G]
    (S : Finset G) (ε : ℝ) : Prop :=
  HasVertexExpansion S ε ∧ (∀ g : G, g ∈ Subgroup.closure (S : Set G))

/-! ## Section 4: Main Theorems -/

/-! ### Theorem 1: Certificate implies irreducible action -/

/-
**Theorem 1 (No invariant submodule from classical certificate).**

If `(s, t)` satisfy the classical generation certificate — meaning `s` has
irreducible characteristic polynomial and `t` breaks all proper `s`-invariant
subspaces — then no proper nontrivial 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Fibonacci Entry Point as a Lattice-Respecting Arithmetic Function

## Synthesis of this cycle

This cycle closed the open `sorry` in
`Catalog/Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean` and
promoted the *entry point* (rank of apparition) `α(m) = least k > 0 with m ∣ F(k)`
from a single divisibility identity into a fully fledged arithmetic function on
the divisibility lattice of moduli admitting an apparition index.

Concretely, four theorems are now proved sorry-free (axioms: `propext`,
`Classical.choice`, `Quot.sound` only):

* `fibEntryPt_mul_coprime` — **the lcm law** `α(a·b) = lcm(α a, α b)` for coprime
  `a, b` (this was the cycle's target `sorry`).
* `fibEntryPt_dvd_of_dvd` — **monotonicity** `a ∣ b ⟹ α(a) ∣ α(b)`.
* `fib_dvd_mul_coprime_iff` — **product criterion** `a·b ∣ F(k) ↔ lcm(α a, α b) ∣ k`.
* `fib_dvd_mul_setOf_eq_inter` — **set form** the index set of `a·b` is the
  intersection of the index sets of `a` and `b`.

The unifying engine is the catalog's characterization theorem
`fib_dvd_iff_entryPt_dvd` (`m ∣ F(k) ↔ α(m) ∣ k`), whose proof never uses
primality and is therefore the *universal property* of `α`: the index set of any
modulus is the principal ideal `(α(m)) ⊆ ℕ`. Every result above is a short
consequence of that universal property plus elementary lattice facts.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `fibEntryPt_mul_coprime` | `α(a·b) = lcm(α a, α b)`, `gcd(a,b)=1` | proved |
| `fibEntryPt_dvd_of_dvd` | `a ∣ b ⟹ α a ∣ α b` | proved |
| `fib_dvd_mul_coprime_iff` | `a·b ∣ F k ↔ lcm(α a, α b) ∣ k` | proved |
| `fib_dvd_mul_setOf_eq_inter` | index set of `a·b` = intersection | proved |
| `fib_carmichael_composite` (tail) | primitive divisor for composite `n > 10000` | **open** |

The boundary obstruction `fib_twelve_no_primitive` (`F(12) = 144` has no
primitive prime divisor) remains the structural reason any primitive-divisor
statement must exclude `n = 12`.

## Research directions

### 1. Full factorization reconstruction of the entry point

Conjecture: for every `m > 0` admitting an apparition index,
`α(m) = ` the lcm, taken over the prime-power factors `pᵉ ∥ m`, of `α(pᵉ)`. This
is the multi-factor closure of the binary lcm law proved this cycle, and is
*falsifiable*: a single `m` whose entry point differs from that lcm refutes it.
**The key insight is** that coprimality is the only hypothesis the binary law
needs, so an induction over the coprime factorization `m = ∏ pᵉ` should lift it
verbatim — the lcm law is associative-commutative precisely because `lcm` is. **Why
now?** With `fibEntryPt_mul_coprime` and `fibEntryPt_dvd_of_dvd` in hand, the
inductive step (`α(a·b) = lcm(α a, α b)` plus monotonicity to glue the pieces) is
fully mechanized; only a `Nat.factorization`/`Finset.prod` bookkeeping layer is
missing.

### 2. The prime-power growth law (lifting the exponent)

Conjecture: there is an integer `e₀(p) ≥ 1` such that for all `k ≥ e₀(p)`,
`α
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
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
