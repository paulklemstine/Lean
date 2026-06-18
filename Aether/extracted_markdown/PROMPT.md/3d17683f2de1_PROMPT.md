
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   Reference the specific theorems proved in Phase A using @file references.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work,
   references to catalog results. Use @file references for theorems.
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
Use the @file references above to point readers to specific theorems.


## Concept

**Title**: The tropical analogue of eigenvalues — values λ such that A ⊗ x = λ ⊗ x in the t
**Domain**: Computation
**Mathematical framing**: # Future Directions: Tropical Phase Transition Thresholds

## 1. Tropical Spectral Theory and Eigenvalue Phase Transitions

The tropical analogue of eigenvalues — values λ such that A ⊗ x = λ ⊗ x in the tropical semiring — exhibits a remarkable phase transition structure. For tropical matrices with entries drawn from random distributions, the critical cycle mean (the tropical eigenvalue) undergoes a sharp transition as the matrix density crosses a threshold, analogous to the giant component transition in random graphs.

The key insight is that tropical eigenvalues are determined by the maximum cycle mean in the associated directed graph, which connects graph connectivity thresholds to algebraic spectral transitions. Why now? Our formalization of `tropical_sum_eq_trop_inf'` and `tropical_threshold_dichotomy` provides the algebraic foundation for characterizing when cycle means achieve their critical values. The next step is formalizing tropical matrix powers A^k and proving that the sequence trop_trace(A^k)/k converges to the tropical spectral radius, with a sharp transition in the number of cycles achieving the maximum.

## 2. Tropical Convexity and Hyperplane Arrangement Complexity

The sub-level closure theorem (`tropical_sublevel_closed`) opens the door to a full theory of tropical convexity. A tropical polytope — the tropical convex hull of finitely many points — has a combinatorial type determined by which "phase" each face is in (i.e., which term achieves the minimum). The conjecture is that the number of distinct combinatorial types of tropical polytopes with n vertices in dimension d exhibits a phase transition at d ≈ log n, below which all polytopes are "simple" (each vertex has a unique minimizer) and above which exponentially many combinatorial types appear.

The key insight is that tropical convexity is equivalent to min-plus convexity, and the combinatorial explosion of face types is governed by the same threshold phenomena we formalized in `tropical_threshold_dichotomy`. Why now? The algebraic infrastructure for tropical sums as infima and the witness theorem provides the correct language for counting face types. Formalizing the tropical Carathéodory theorem (every point in the tropical convex hull of S lies in the tropical convex hull of at most d+1 points from S) would be the next concrete target.

## 3. Tropical Bellman-Ford Convergence and Shortest-Path Phase Transitions

The idempotent iteration theorem (`tropical_idempotent_nsmul`) generalizes to tropical matrix powers: for an n×n tropical matrix A, the sequence A, A^2, A^3, ... stabilizes at A^(n-1) (if no negative cycles exist). This is exactly the Bellman-Ford algorithm. The conjecture is that for random tropical matrices with entry distribution parameterized by density ρ, the stabilization time undergoes a sharp threshold: for ρ < ρ_c the matrix power stabilizes in O(1) steps, while for ρ > ρ_c it requires Θ(n) steps, with the transition governed by the emergence of long shortest paths.

The key insight is that stabilization time equals the longest shortest path (the diameter of the implicit weighted graph), which has a known phase transition in random graph theory. Why now? Our formalization of tropical idempotent iteration provides the algebraic framework for reasoning about stabilization, and the parameterized phase transition theorems give the tools for formalizing the sharp threshold. The next step is defining tropical matrix multiplication and proving A^n = A^(n-1) for matrices without negative cycles.

## 4. Tropical Proof Complexity and Resource Thresholds

The original motivation for this work: can tropical algebra formalize phase transitions in proof search? The conjecture is that for a natural ensemble of tropical optimization problems of size n (e.g., random tropical linear programs), the probability of finding a feasible solution undergoes a sharp threshold at a critical constraint density ρ_c = 1, and moreover, the "proof" of feasibility (a witness point) has size that diverges as ρ → ρ_c from below, analogous to resolution proof complexity near the SAT threshold.

The key insight is that `tropical_sum_witness` gives a constructive witness for every tropical sum, but the number of potential witnesses grows combinatorially, and near the threshold, the witnesses become highly constrained. Why now? Our framework provides the first formalized connection between tropical algebraic operations and combinatorial witness structures. The next step is defining tropical linear feasibility (does x exist such that A ⊗ x ≤ b in the tropical sense?) and characterizing the feasibility boundary.

## 5. Tropical Entropy and Information-Theoretic Phase Transitions

Define the "tropical entropy" of a finite tropical sum ∑ᵢ trop(aᵢ) as the logarithm of the number of indices i that are "near-optimal" (within ε of the minimum). As ε → 0, this quantity drops to log(k) where k is the number of exact minimizers. The conjecture is that for random i.i.d. entries aᵢ, the expected tropical entropy exhibits a phase transition at ε_c = Θ(1/n) from logarithmic growth (many near-minimizers) to constant (unique minimizer).

The key insight is that `tropical_threshold_dichotomy` shows the transition between "a wins" and "b wins" is sharp — but with noise, multiple terms can be near the minimum simultaneously, creating an entropy landscape. Why now? Our formalization of the witness theorem and the parameterized threshold gives the exact framework for counting near-minimizers. The next step is defining the ε-witness set {i ∈ s : f(i) ≤ inf'(f) + ε} and proving it shrinks to a singleton as ε → 0, with a rate depending on the gap structure.

Research domain: Computation
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/DeepConnections.lean
import Mathlib

/-! # CatalogBuild.Speculative.Other.DeepConnections

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 12
-/

noncomputable section

/-- Chebyshev polynomial of the first kind, defined by recurrence -/
noncomputable def chebyT : ℕ → Polynomial ℤ
  | 0 => 1
  | 1 => Polynomial.X
  | (n + 2) => 2 * Polynomial.X * chebyT (n + 1) - chebyT n

/-- **THEOREM 17**: T₀ = 1 -/
theorem chebyT_zero : chebyT 0 = 1 := by rfl

/-- **THEOREM 18**: T₁ = X -/
theorem chebyT_one : chebyT 1 = Polynomial.X := by rfl

/-- [Section: # CatalogBuild.Speculative.Other.DeepConnections
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 12] -/
theorem chebyT_degree (n : ℕ) (hn : 1 ≤ n) :
    (chebyT n).natDegree = n := by
      induction' n using Nat.strong_induction_on with n ih; rcases n with _|_|n; simp_all +decide [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ] ;
      · exact Polynomial.natDegree_X;
      · erw [ show chebyT ( n + 2 ) = 2 * Polynomial.X * chebyT ( n + 1 ) - chebyT n from rfl ] ; erw [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ] <;> erw [ Polynomial.natDegree_mul' ] <;> norm_num [ ih ] ; ring_nf ;
        · exact ne_of_apply_ne Polynomial.natDegree ( by erw [ ih _ ( Nat.lt_succ_self _ ) ( Nat.succ_pos _ ) ] ; norm_num );
        · by_cases hn : 1 ≤ n <;> simp_all +arith +decide [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ];
          erw [ chebyT_zero ] ; norm_num;
        · exact ne_of_apply_ne Polynomial.natDegree ( by erw [ ih _ ( Nat.lt_succ_self _ ) ( Nat.succ_pos _ ) ] ; norm_num )

/-- [Section: # CatalogBuild.Speculative.Other.DeepConnections
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 12] -/
theorem chebyT_comp (m n : ℕ) :
    (chebyT m).comp (chebyT n) = chebyT (m * n) := by
      -- By definition of Chebyshev polynomials, we know that $T_{m}(T_{n}(x))$ satisfies the same recurrence relation as $T_{mn}(x)$.
      have h_recurrence : ∀ m n : ℕ, (chebyT (m * n)).comp (Polynomial.X) = (chebyT m).comp (chebyT n) := by
        intro m n;
        -- By definition of Chebyshev polynomials, we know that $T_{m}(T_{n}(x))$ satisfies the same recurrence relation as $T_{mn}(x)$ and the same initial conditions.
        have h_recurrence : ∀ m n : ℕ, ∀ x : ℝ, -1 ≤ x ∧ x ≤ 1 → (chebyT (m * n)).eval₂ (algebraMap ℤ ℝ) x = (chebyT m).eval₂ (algebraMap ℤ ℝ) ((chebyT n).eval₂ (algebraMap ℤ ℝ) x) := by
          intros m n x hx
          have h_recurrence : ∀ m n : ℕ, ∀ x : ℝ, -1 ≤ x ∧ x ≤ 1 → (chebyT (m * n)).eval₂ (algebraMap ℤ ℝ) x = (chebyT m).eval₂ (algebraMap ℤ ℝ) ((chebyT n).eval₂ (algebraMap ℤ ℝ) x) := by
            intros m n x hx
            have h_cheby : ∀ n : ℕ, ∀ θ : ℝ, (chebyT n).eval₂ (algebraMap ℤ ℝ) (Real.cos θ) = Real.cos (n * θ) := by
              intro n θ; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.succ_eq_add_one, add_mul, Real.cos_add ] ;
              · erw [ show chebyT 0 = 1 from rfl ] ; norm_num;
              · erw [ Polynomial.eval₂_X ];
              · erw [ show chebyT ( n + 2 ) = 2 * Polynomial.X * chebyT ( n + 1 ) - chebyT n from rfl ] ; norm_num [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ), Real.sin_add, Real.cos_add ] ; ring;
                rw [ Real.sin_sq, Real.cos_add ] ; ring
            convert h_cheby ( m * n ) ( Real.arccos x ) using 1 <;> simp +decide [ Real.cos_arccos hx.1 hx.2, h_cheby ];
            convert h_cheby m ( n * Real.arccos x ) using 1 ; ring;
            · rw [ ← h_cheby ] ; norm_num [ Real.cos_arccos hx.1 hx.2 ];
            · ring;
          exact h_recurrence m n x hx;
        -- Since these polynomials agree on the interval $[-1, 1]$, they must be equal.
        have h_poly_eq : ∀ p q : Polynomial ℤ, (∀ x : ℝ, -1 ≤ x ∧ x ≤ 1 → p.eval₂ (algebraMap ℤ ℝ) x = q.eval₂ (algebraMap ℤ ℝ) x) → p = q := by
          intros p q h_eq
          have h_poly_eq : (p.map (algebraMap ℤ ℝ)) = (q.map (algebraMap ℤ ℝ)) := by
            have h_poly_eq : Set.Infinite {x : ℝ | (p.map (algebraMap ℤ ℝ)).eval x = (q.map (algebraMap ℤ ℝ)).eval x} := by
              exact Set.Infinite.mono ( fun x hx => by simpa [ Polynomial.eval₂_eq_eval_map ] using h_eq x hx ) ( Set.Icc_infinite ( by norm_num ) );
            exact Classical.not_not.1 fun h => h_poly_eq <| Set.Finite.subset ( Polynomial.map ( algebraMap ℤ ℝ ) p - Polynomial.map ( algebraMap ℤ ℝ ) q |> Polynomial.roots |> Multiset.toFinset |> Finset.finite_toSet ) fun x hx => by simp_all +decide [ sub_eq_iff_eq_add ] ;
          exact Polynomial.map_injective ( algebraMap ℤ ℝ ) Int.cast_injective <| by simpa using h_poly_eq;
        exact h_poly_eq _ _ fun x hx => by simpa [ Polynomial.eval₂_comp ] using h_recurrence m n x hx;
      simpa using Eq.symm ( h_recurrence m n )

/-- A solution to the Pell equation x² - D·y² = 1 -/
structure PellSolution (D : ℤ) where
  x : ℤ
  y : ℤ
  eq : x^2 - D * y^2 = 1

/-- The trivial solution -/
def PellSolution.trivial (D : ℤ) : PellSolution D := ⟨1, 0, by ring⟩

/-- Composing two Pell solutions (the "Brahmagupta composition") -/
def PellSolution.compose (D : ℤ) (s₁ s₂ : PellSolution D) : PellSolution D where
  x := s₁.x * s₂.x + D * s₁.y * s₂.y
  y := s₁.x * s₂.y + s₁.y * s₂.x
  eq := by nlinarith [s₁.eq, s₂.eq, sq_nonneg (s₁.x * s₂.x + D * s₁.y * s₂.y),
                       sq_nonneg (s₁.x * s₂.y + s₁.y * s₂.x),
                       sq_nonneg (s₁.x * s₂.x - D * s₁.y * s₂.y),
                       sq_nonneg (s₁.x * s₂.y - s₁.y * s₂.x)]

theorem pell_compose_assoc (D : ℤ) (s₁ s₂ s₃ : PellSolution D) :
    PellSolution.compose D (PellSolution.compose D s₁ s₂) s₃ =
    PellSolution.compose D s₁ (PellSolution.compose D s₂ s₃) := by
      -- By definition of PellSolution.mk, we can unfold the composition and show that both sides are equal.
      simp [PellSolution.mk, PellSolution.compose] at *;
      constructor <;> ring

theorem pell_compose_trivial_left (D : ℤ) (s : PellSolution D) :
    PellSolution.compose D (PellSolution.trivial D) s = s := by
      cases s ; unfold PellSolution.trivial PellSolution.compose ; aesop

theorem sum_two_sq_mod (p : ℕ) (hp : Nat.Prime p) (hp4 : p % 4 = 1) :
    ∃ a : ZMod p, a^2 = -1 := by
      haveI := Fact.mk hp;
      obtain ⟨ x, hx ⟩ := ZMod.exists_sq_eq_neg_one_iff ( p := p );
      exact Exists.elim ( hx ( by rw [ hp4 ] ; decide ) ) fun a ha => ⟨ a, by rw [ sq, ha ] ⟩

theorem padic_val_add_ge_min (p a b : ℕ) (hp : Nat.Prime p)
    (ha : 0 < a) (hb : 0 < b) :
    padicValNat p (a + b) ≥ min (padicValNat p a) (padicValNat p b) ∨
    a + b = 0 := by
      -- By the properties of the p-adic valuation, if $p^k$ divides both $a$ and $b$, then it also divides their sum $a + b$.
      have h_div : ∀ k, p^k ∣ a → p^k ∣ b → p^k ∣ a + b := by
        exact fun k hk₁ hk₂ => Nat.dvd_add hk₁ hk₂;
      simp_all +decide [ ← Nat.factorization_le_iff_dvd, padicValNat_dvd_iff ];
      contrapose! h_div; aesop;

end


-- NEW_FILE: Catalog/Algebra/Defs.lean
/-
# Arithmetic Monsters: A Formal Theory of Digit-Interaction under Multiplication

This file defines the core concepts of "arithmetic creature theory" — a formal framework
for studying how multiplication interacts with digit representations in arbitrary bases.

The key abstraction is the **digit bag** (digit multiset profile): for a natural number `n`
in base `b`, we track the multiplicity of each digit. This converts ad hoc decimal folklore
(vampire numbers, etc.) into a reusable finite invariant.
-/
import Mathlib

open Finset BigOperators

namespace ArithmeticMonsters

/-! ## Digit Infrastructure -/

/-- The digit bag of `n` in base `b`: counts occurrences of each digit `d ∈ Fin b`.
    For `b ≥ 2`, this is well-defined since `Nat.digits b n` only contains values in `{0, ..., b-1}`.
    For `b < 2`, we define it as the zero function. -/
def digitBag (b : ℕ) (n : ℕ) : Fin b → ℕ :=
  fun d => (
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Tropical Spectral Theory

## 1. Tropical Eigenvalue Formula for General n×n Matrices

The 2×2 eigenvalue formula `tropEigval2(A) = min(A₀₀, A₁₁, (A₀₁+A₁₀)/2)` generalizes to n×n matrices as the minimum cycle mean: `λ(A) = min_{k=1..n} tr(A^k)/k`, where `tr(A^k)` is the minimum weight length-k closed walk. Our `tropical_trace_eigval_2x2` proves this for n=2; the general case requires showing that walk enumeration through matrix powers captures all directed cycles.

The key insight is that `minPlusMul` composes shortest-path computations, so `(A^k)_{ii}` equals the minimum weight walk from i to i of length exactly k, and the infimum over diagonal entries gives the minimum over all starting vertices. Why now? The associativity proof `minPlus_mul_assoc` provides the algebraic backbone — it shows min-plus matrix powers are well-defined and composable. The next step is proving `minPlusPow_entry_eq_min_walk` by induction on k, which reduces the spectral radius formula to a combinatorial identity over the cycle space of the complete directed graph.

## 2. Tropical Cayley–Hamilton and Matrix Power Stabilization

For an n×n min-plus matrix A with no negative-weight cycles (i.e., `tropEigval(A) ≥ 0`), the Bellman–Ford theorem states that the matrix power sequence A, A², A³, ... stabilizes: A^n = A^(n-1) (after suitable normalization). This is the tropical analog of the Cayley–Hamilton theorem. The conjecture is formalizable: define the normalized power `Ã^k := A^k - k·λ(A)·I` (subtracting the eigenvalue from the diagonal) and prove `Ã^n = Ã^(n-1)` for irreducible matrices.

The key insight is that after subtracting the eigenvalue, all cycle means become non-negative, and the critical graph (cycles achieving mean zero) determines the periodicity of the power sequence. Why now? Our `minPlusMul` and `minPlusPow` definitions provide the infrastructure, and `minPlus_mul_assoc` ensures the power sequence is well-defined. The proof should proceed by showing that paths longer than n must revisit a vertex, and non-negative cycle means ensure the shortest path length stabilizes.

## 3. Tropical Eigenvector Uniqueness and the Critical Graph

For a 2×2 matrix, we exhibited three cases for the eigenvector (cycle case, diag0 case, diag1 case). In general, the eigenvector is unique up to tropical scalar multiplication (adding a constant to all entries) if and only if the critical graph — the subgraph consisting of edges participating in minimum-mean cycles — is strongly connected. The conjecture: formalize the critical graph for n×n matrices and prove that strong connectivity of the critical graph implies the tropical eigenspace has "dimension 1" (i.e., all eigenvectors differ by a tropical scalar).

The key insight is that tropical eigenspaces are classical convex cones, and their dimension equals the number of strongly connected components of the critical graph. Why now? The explicit eigenvector constructions in our three case theorems reveal the pa
```

## Your task

Produce the deliverables listed above. Reference the specific theorems and
results in the Lean code by their @file path and statement. The Lean file is
the source of truth — your prose must accurately explain it.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
