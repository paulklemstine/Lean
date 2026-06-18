

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new

## Non-Archimedean Computation: Ultrametric Algorithm Complexity, p-adic Valuation Depth Hierarchies, and Hensel Lifting Speedup Theorems

### I. FOUNDATIONAL DEFINITIONS — New Typeclasses and Structures

Define the following novel structures, each bridging algebra and computation:

```lean
/-- ValuationDepth: the minimum number of valuation queries needed to compute
a function f : α → β over a non-Archimedean valued ring. This is the
non-Archimedean analogue of circuit depth.
Bridge: connects Algebra/valuation_theory to Computation/complexity_classes. -/
class ValuationDepthMeasure (α : Type*) (β : Type*) [Semiring α] [Semiring β] where
  vdepth : (α → β) → ℕ
  vdepth_zero : vdepth (fun _ => 0) = 0
  vdepth_add : ∀ f g, vdepth (fun x => f x + g x) ≤ max (vdepth f) (vdepth g) + 1
  vdepth_mul : ∀ f g, vdepth (fun x => f x * g x) ≤ max (vdepth f) (vdepth g) + 1

/-- ValDepthClass k: the class of functions computable with valuation depth ≤ k.
Analogue of AC⁰ vs NC¹ but in the ultrametric world.
Bridge: connects Computation/circuit_complexity to Algebra/p_adic_analysis. -/
structure ValDepthClass (p : ℕ) [hp : Fact p.Prime] (k : ℕ) where
  carrier : Set (ℤ_[p] → ℤ_[p])
  depth_bound : ∀ f ∈ carrier, ValuationDepthMeasure.vdepth f ≤ k
  closure_under_composition : -- functions in ValDepthClass k compose with depth ≤ k

/-- HenselCertificate: a verified certificate that p-adic Newton iteration
converges, with explicit exponential convergence rate.
Bridge: connects Algebra/hensels_lemma to Cryptography/post_quantum_verification. -/
structure HenselCertificate (p : ℕ) [hp : Fact p.Prime] (f : ℤ_[p] → ℤ_[p]) where
  x₀ : ℤ_[p]
  h₀ : f x₀ ≡ 0 [MOD p]
  vderiv : ℤ_[p]  -- |f'(x₀)|_p
  vderiv_ne : vderiv ≠ 0  -- f'(x₀) is a unit in ℤ_[p]
  convergence_steps : ℕ → ℕ  -- n ↦ valuation of residual after n steps
  quadratic_bound : ∀ n, convergence_steps n ≥ 2^n  -- exponential convergence

/-- UltrametricLipschitzAlgorithm: an algorithm whose certified Lipschitz constant
in the ultrametric satisfies the ultrametric composition law (max instead of sum).
Bridge: connects ML/certified_robustness to Algebra/ultrametric_spaces. -/
structure UltrametricLipschitzAlgorithm (p : ℕ) [hp : Fact p.Prime] (f : ℤ_[p] → ℤ_[p]) where
  lipschitz_const : ℕ  -- p^l is the Lipschitz constant
  ultrametric_lipschitz : ∀ x y, ‖f x - f y‖ₚ ≤ max ‖x - y‖ₚ (p^(-lipschitz_const : ℤ))
  -- Key: composition uses MAX not SUM (unlike classical Lipschitz)
  composition_law : ∀ g hg, lipschitz_const (f ∘ g) = max lipschitz_const hg.lipschitz_const

/-- PadicCryptoHardness: a function whose valuation depth is a lower bound
on the complexity of any algorithm computing it — relevant to post-quantum
lattice-based cryptography over p-adic rings.
Bridge: connects Cryptography/lattice_problems to Algebra/p_adic_valuation. -/
structure PadicCryptoHardness (p : ℕ) [hp : Fact p.Prime] where
  hard_fn : ℤ_[p] → ℤ_[p]
  depth_lower : ∀ k, ValuationDepthMeasure.vdepth hard_fn > k → -- hard_fn ∉ ValDepthClass p k
  lattice_reduction_bound : -- connection to SVP hardness over p-adic lattices
```

### II. THEOREM 1: Ultrametric Locality — Constant Valuation Depth for p-adic Arithmetic

**Statement (Lean 4 signature)**:
```lean
/-- Bridge: connects Algebra/padic_valuation to Computation/arithmetic_circuit_complexity.
The ultrametric inequality eliminates carry propagation: p-adic addition and
multiplication require only O(1) valuation depth, whereas classical arithmetic
requires Ω(log n) depth due to carry chains. This is the foundational speedup
theorem for non-Archimedean computation. -/
theorem ultrametric_valuation_depth_constant {p : ℕ} [hp : Fact p.Prime] :
    ∀ (a b : ℤ_[p]),
      ValuationDepthMeasure.vdepth (fun _ => a + b) ≤ 1 ∧
      ValuationDepthMeasure.vdepth (fun _ => a * b) ≤ 1 := by
  sorry -- FILL: this is the core theorem

/-- The classical lower bound: in ℕ, carry propagation forces Ω(log n) depth.
This is the counterpart showing WHERE the speedup comes from. -/
theorem classical_carry_propagation_depth_lower {n : ℕ} (hn : n ≥ 2) :
    ∃ (a b : ℕ), a < n ∧ b < n ∧
      (circuit_depth_of_add a b : ℕ) ≥ Nat.log 2 n := by
  sorry -- FILL: witness construction with binary carry chains

/-- The quantitative speedup: p-adic arithmetic is exponentially faster
in valuation depth than classical arithmetic. -/
theorem padic_vs_classical_speedup {p : ℕ} [hp : Fact p.Prime] {n : ℕ} (hn : n ≥ 2) :
    ∃ (C : ℕ), C = 1 ∧
      ∀ (a b : ℤ_[p]), -- p-adic: O(1) depth
        ValuationDepthMeasure.vdepth (fun _ => a + b) ≤ C ∧
      ∃ (a b : ℕ), a < p^n ∧ b < p^n ∧ -- classical: Ω(n) depth
        (circuit_depth_of_add a b : ℕ) ≥ n := by
  sorry -- FILL: combine the two bounds
```

**Proof Strategy (3 paths, ranked by promise)**:

*Strategy A (Direct ultrametric computation — MOST PROMISING)*:
1. Prove `ultrametric_valuation_depth_step`: For any `a b : ℤ_[p]`, the valuation `v_p(a+b)` is determined by `v_p(a)` and `v_p(b)` alone when `v_p(a) ≠ v_p(b)`, using the strong triangle inequality.
2. Prove `valuation_query_suffices`: A single valuation query `v_p(a+b)` suffices because the ultrametric inequality gives `v_p(a+b) ≤ max(v_p(a), v_p(b))`, and equality holds when `v_p(a) ≠ v_p(b)` — no carry propagation needed.
3. Combine with `ValuationDepthMeasure.vdepth_add` to get depth ≤ 1.
4. For multiplication, use `v_p(a*b) = v_p(a) + v_p(b)` (exact, no carry) to get depth ≤ 1.
5. Key lemma: `ultrametric_strict_triangle`: `v_p(a) ≠ v_p(b) → v_p(a+b) = max(v_p(a), v_p(b))`.

*Strategy B (Via digit expansions)*:
1. Show that p-adic digits of `a+b` at position `k` depend only on digits of `a` and `b` at position `k` (no carry from position `k-1`).
2. This is false in general — carry CAN propagate when digits sum to ≥ p. But the *valuation* (the position of the first nonzero digit) is determined locally.
3. This approach is less direct; Strategy A is preferred.

*Strategy C (Via topological properties of ℤ_p)*:
1. Use the fact that `ℤ_p` is totally disconnected and each ball is clopen.
2. Show that the map `(a,b) ↦ a+b` is locally constant on any ball of radius `p^{-k}`.
3. Conclude that valuation depth is bounded by the number of balls, which is O(1).
4. This is elegant but requires more topological infrastructure.

### III. THEOREM 2: Valuation Depth Hierarchy — VAL_k ⊊ VAL_{k+1}

**Statement**:
```lean
/-- Bridge: connects Computation/complexity_hierarchies to Algebra/hensel_lifting.
The valuation depth hierarchy is strict: each additional level of valuation depth
enables exactly one more Hensel lifting step. Witness functions are constructed
from iterated p-adic root-finding. This is the non-Archimedean analogue of
the time hierarchy theorem. -/
theorem valuation_depth_hierarchy_separation {p : ℕ} [hp : Fact p.Prime] (k : ℕ) :
    ∃ (f : ℤ_[p] → ℤ_[p]),
      f ∈ (ValDepthClass p k).carrierᶜ ∧
      f ∈ (ValDepthClass p (k + 1)).carrier := by
  sorry -- FILL: construct witness via Hensel iteration

/-- The witness function: applying k+1 rounds of Hensel lifting to a
polynomial with a simple root mod p. Each round doubles the valuation
of the approximation, so k+1 rounds require valuation depth k+1. -/
theorem hensel_witness_requires_depth {p : ℕ} [hp : Fact p.Prime] {k : ℕ}
    (f : ℤ_[p][X]) (x₀ : ℤ_[p])
    (hf : f.eval x₀ ≡ 0 [MOD p]) (hf' : ¬(f.deriv.eval x₀ ≡ 0 [MOD p])) :
    ∃ (g : ℤ_[p] → ℤ_[p]),
      g = hensel_iterate f x₀ (k + 1) ∧
      ValuationDepthMeasure.vdepth g = k + 1 := by
  sorry -- FILL: inductive construction

/-- Composition law for valuation depth: the depth of f ∘ g is at most
the sum of depths, but in the ultrametric setting it can be bounded by
max + 1 due to the ultrametric locality. -/
theorem valuation_depth_ultrametric_composition {p : ℕ} [hp : Fact p.Prime]
    {f g : ℤ_[p] → ℤ_[p]} (hf : ValuationDepthMeasure.vdepth f = k₁)
    (hg : ValuationDepthMeasure.vdepth g = k₂) :
    ValuationDepthMeasure.vdepth (fun x => f (g x)) ≤ max k₁ k₂ + 1 := by
  sorry -- FILL: use ultrametric locality
```

**Proof Strategy**:

1. **Base case** (`valuation_depth_hierarchy_base`): Prove VAL_0 ⊊ VAL_1. The constant functions are in VAL_0. The identity function `id : ℤ_[p] → ℤ_[p]` is in VAL_1 \ VAL_0 because computing `v_p(x)` requires one valuation query.

2. **Inductive step**: Given `f_k ∈ VAL_{k+1} \ VAL_k`, construct `f_{k+1} ∈ VAL_{k+2} \ VAL_{k+1}` by composing `f_k` with one Hensel lifting step.

3. **Key lemma** (`hensel_step_increases_depth`): A single Hensel iteration `x ↦ x - f(x)/f'(x)` increases valuation depth by exactly 1, because it requires evaluating `f` (depth = k) and `f'` (depth = k), then dividing (depth = 1 additional query to check `f'(x)` is a unit).

4. **Hardness lemma** (`depth_lower_bound_via_valuation`): If `g` computes a root of `f` mod `p^{2^{k+1}}` but no function of depth ≤ k can do so, then `vdepth(g) ≥ k+1`. Prove by showing that depth-k functions can only track `2^k` valuation bits.

### IV. THEOREM 3: Hensel Speedup — Exponential Convergence in Valuation Depth

**Statement**:
```lean
/-- Bridge: connects Algebra/hensels_lemma to Cryptography/certified_root_finding
and ML/exponential_convergence_rates.
Hensel's lemma gives QUADRATIC convergence in valuation: each Newton step
doubles the p-adic valuation of the residual. This means n correct p-adic
digits are computed in O(log n) valuation steps — exponentially faster than
any classical root-finding method (which requires Ω(n) iterations for linear
convergence). -/
theorem hensel_quadratic_valuation_convergence {p : ℕ} [hp : Fact p.Prime]
    {f : ℤ_[p][X]} {x₀ : ℤ_[p]}
    (hf₀ : f.eval x₀ ≡ 0 [MOD p])
    (hf' : ¬(f.deriv.eval x₀ ≡ 0 [MOD p])) :
    ∀ (n : ℕ),
      let xₙ := hensel_iterate f x₀ n
      v_p (f.eval xₙ) ≥ 2^n := by
  sorry -- FILL: inductive proof

/-- Certified complexity: the exact number of valuation steps needed
to compute n correct p-adic digits of a root. -/
theorem hensel_certified_digit_complexity {p : ℕ} [hp : Fact p.Prime]
    {f : ℤ_[p][X]} {x₀ : ℤ_[p]}
    (hf₀ : f.eval x₀ ≡ 0 [MOD p])
    (hf' : ¬(f.deriv.eval x₀ ≡ 0 [MOD p]))
    (n : ℕ) (hn : n ≥ 1) :
    ∃ (steps : ℕ), steps = Nat.log 2 n + 1 ∧
      let xₛ := hensel_iterate f x₀ steps
      v_p (f.eval xₛ) ≥ n ∧
      steps < n := by  -- O(log n) vs Ω(n) classical
  sorry -- FILL: combine quadratic convergence with log bound

/-- The exponential speedup: no classical iterative method can match
Hensel lifting's convergence rate for p-adic root finding. -/
theorem hensel_exponential_speedup_vs_classical {p : ℕ} [hp : Fact p.Prime]
    {f : ℤ_[p][X]} {x₀ : ℤ_[p]}
    (hf₀ : f.eval x₀ ≡ 0 [MOD p])
    (hf' : ¬(f.deriv.eval x₀ ≡ 0 [MOD p]))
    (n : ℕ) (hn : n ≥ 1) :
    ∃ (steps : ℕ),
      steps = Nat.log 2 n + 1 ∧
      ∀ (classical_iter : ℕ → ℤ_[p]),
        (∀ k, v_p (f.eval (classical_iter k)) ≥ k + 1) →
        (classical_iter n).1 ≥ n := by  -- classical needs n iterations
  sorry -- FILL: lower bound on classical iteration
```

**Proof Strategy for `hensel_quadratic_valuation_convergence`**:

1. **Base case** (`n = 0`): `v_p(f.eval x₀) ≥ 1` follows from `hf₀`.
2. **Inductive step**: Assume `v_p(f.eval xₙ) ≥ 2^n`. Show `v_p(f.eval xₙ₊₁) ≥ 2^{n+1}`.
   - Unfold `xₙ₊₁ = xₙ - f(xₙ)/f'(xₙ)`.
   - Taylor expand: `f(xₙ₊₁) = f(xₙ) - f(xₙ) · f'(xₙ)/f'(xₙ) + (1/2)f''(xₙ)(f(xₙ)/f'(xₙ))² + ...`
   - Key step: `v_p(f(xₙ)² / f'(xₙ)²) ≥ 2 · 2^n - 2·v_p(f'(xₙ))⁻¹ ≥ 2^{n+1}` because `v_p(f'(xₙ)) = v_p(f'(x₀)) = 0` (unit).
   - Use `ultrametric_strict_triangle` to show the quadratic term dominates.
3. **Critical lemma** (`padic_taylor_valuation_bound`): For `f` polynomial over `ℤ_[p]`, `v_p(f(x+h) - f(x) - f'(x)·h) ≥ 2·v_p(h)` when `v_p(h) ≥ 1`.
4. **Unit preservation** (`hensel_deriv_remains_unit`): If `v_p(f'(x₀)) = 0` and `v_p(xₙ - x₀) ≥ 1`, then `v_p(f'(xₙ)) = 0` — the derivative remains a unit throughout iteration.

### V. CROSS-DOMAIN THEOREMS — Bridging to Cryptography and ML

```lean
/-- Bridge: connects Algebra/padic_valuation to Cryptography/post_quantum_security.
The valuation depth of the shortest vector problem (SVP) over p-adic lattices
provides a LOWER BOUND on the quantum query complexity of any algorithm solving
SVP. This gives a post-quantum security reduction. -/
theorem padic_svp_valuation_depth_quantum_lower_bound {p : ℕ} [hp : Fact p.Prime]
    {d : ℕ} (B : Matrix (Fin d) (Fin d) ℤ_[p]) (hB : B ∈ padic_lattice_basis d) :
    ∀ (quantum_query : ℕ → ℤ_[p]),
      ValuationDepthMeasure.vdepth quantum_query ≥ d - 1 →
      ∀ (approx : Fin d → ℤ_[p]),
        shortest_vector_approx B approx →
        v_p (Lattice.shortVec B - approx) ≥ 1 := by
  sorry -- FILL: quantum query lower bound via valuation depth

/-- Bridge: connects ML/certified_robustness to Algebra/ultrametric_spaces.
In ultrametric spaces, the Lipschitz constant of a composed function is
the MAX of individual constants (not the product). This gives certified
robustness bounds for neural networks over p-adic feature spaces that
are EXPONENTIALLY tighter than classical Lipschitz bounds. -/
theorem ultrametric_lipschitz_certified_robustness {p : ℕ} [hp : Fact p.Prime]
    {L : ℕ} {f : (ℤ_[p])^d → (ℤ_[p])^d}
    (hf : ∀ x y, ‖f x - f y‖ₚ ≤ p^(-L : ℤ) * ‖x - y‖ₚ)
    {ε : ℤ} (hε : ε > 0) :
    ∀ (x : (ℤ_[p])^d) (δ : ℤ),
      δ ≥ -ε + L →
      ∀ y, ‖x - y‖ₚ ≤ p^δ → ‖f x - f y‖ₚ ≤ p^(-ε : ℤ) := by
  sorry -- FILL: ultrametric Lipschitz implies certified robustness

/-- Bridge: connects Algebra/hensel_lifting to Cryptography/error_correcting_codes.
Hensel lifting naturally defines an error-correcting code over ℤ/p^nℤ:
each lifting step corrects one "digit" of error. The minimum distance
of the Hensel code H(p, k, n) is p^{2^k}, giving exponentially good
error correction in the code length n. -/
theorem hensel_code_minimum_distance {p : ℕ} [hp : Fact p.Prime] {k n : ℕ}
    (hk : k ≥ 1) (hn : n ≥ 2^k) :
    ∃ (C : Set (ℤ_[p]^k)), C.EncryptionScheme ∧
      (∀ (x y : ℤ_[p]^k), x ∈ C → y ∈ C → x ≠ y →
        hamming_distance x y ≥ p^(2^k : ℕ)) ∧
      card C = p^k := by
  sorry -- FILL: Hensel code construction and distance bound
```

### VI. SUPPORTING LEMMAS — Building the Proof Infrastructure

```lean
/-- The strong ultrametric inequality with strict case: when valuations differ,
the sum's valuation equals the maximum. -/
lemma ultrametric_strict_valuation {p : ℕ} [hp : Fact p.Prime] {a b : ℤ_[p]}
    (h : v_p a ≠ v_p b) : v_p (a + b) = max (v_p a) (v_p b) := by
  sorry -- FILL: by_contra + valuation properties

/-- p-adic valuation is a homomorphism on units: v_p(a*b) = v_p(a) + v_p(b). -/
lemma padic_valuation_mul {p : ℕ} [hp : Fact p.Prime] {a b : ℤ_[p]} :
    v_p (a * b) = v_p a + v_p b := by
  sorry -- FILL: direct from valuation axioms

/-- Hensel step preserves the unit property of the derivative. -/
lemma hensel_deriv_preserves_unit {p : ℕ} [hp : Fact p.Prime]
    {f : ℤ_[p][X]} {x₀ x : ℤ_[p]}
    (hf' : v_p (f.deriv.eval x₀) = 0) (hx : v_p (x - x₀) ≥ 1) :
    v_p (f.deriv.eval x) = 0 := by
  sorry -- FILL: use continuity of f' and ultrametric inequality

/-- Taylor remainder valuation bound: the key estimate for quadratic convergence. -/
lemma padic_taylor_valuation_remainder {p : ℕ} [hp : Fact p.Prime]
    {f : ℤ_[p][X]} {x h : ℤ_[p]}
    (hf : f.coeff.All (fun c => v_p c ≥ 0)) (hh : v_p h ≥ k) :
    v_p (f.eval (x + h) - f.eval x - f.deriv.eval x * h) ≥ 2 * k := by
  sorry -- FILL: induction on degree of f + ultrametric inequality

/-- Classical carry propagation: addition of two n-bit numbers requires
Ω(n) gate depth due to carry chains. -/
lemma classical_carry_chain_lower {n : ℕ} (hn : n ≥ 1) :
    ∃ (a b : ℕ), a < 2^n ∧ b < 2^n ∧
      ∀ (circuit : AddCircuit n), circuit.depth ≥ n := by
  sorry -- FILL: construct worst-case inputs with full carry propagation

/-- Valuation depth composes via max in the ultrametric setting. -/
lemma valuation_depth_ultrametric_composition_le {p : ℕ} [hp : Fact p.Prime]
    {f g : ℤ_[p] → ℤ_[p]} {k₁ k₂ : ℕ}
    (hf : ValuationDepthMeasure.vdepth f ≤ k₁)
    (hg : ValuationDepthMeasure.vdepth g ≤ k₂) :
    ValuationDepthMeasure.vdepth (fun x => f (g x)) ≤ max k₁ k₂ + 1 := by
  sorry -- FILL: single additional query needed to determine composition
```

### VII. FUTURE DIRECTIONS

After completing the above, produce a structured **FUTURE_DIRECTIONS.md** with these concrete next steps:

1. **Non-Archimedean P vs NP**: Define the p-adic analogue of P and NP using valuation depth and p-adic quantifier depth. Is VAL-HIERARCHY = P_p? Can we prove an oracle separation?

2. **p-adic Cryptographic Primitives**: Use the Hensel speedup theorem to construct a one-way function based on the gap between forward Hensel lifting (O(log n) depth) and inverse valuation recovery (O(n) depth). This would give a post-quantum secure primitive.

3. **Ultrametric Neural Network Certification**: Extend the ultrametric Lipschitz composition law to deep ReLU networks over ℚ_p. The max-composition law would give certified robustness radii that are exponentially tighter than classical Lipschitz bounds — a direct application to adversarial ML defense.

4. **Valuation Depth and Quantum Query Complexity**: Prove that quantum query complexity over p-adic inputs is lower-bounded by valuation depth. This would establish the first provable quantum advantage/disadvantage in non-Archimedean computation.

5. **Hensel Codes as Post-Quantum Error-Correcting Codes**: Develop the algebraic theory of Hensel codes with exponentially good minimum distance, and prove their decoding is in VAL_1 (constant valuation depth) — making them efficiently decodable with certified correctness.

### VIII. FILE STRUCTURE EXPECTATION

Produce files across MULTIPLE domains:

- **`Bridges/NonArchimedeanComputation.lean`** (1000+ lines): Core definitions (`ValuationDepthMeasure`, `ValDepthClass`, `HenselCertificate`, `UltrametricLipschitzAlgorithm`) and the three main theorems with full proofs. 30+ theorems, 15+ definitions.

- **`Algebra/PadicValuationDepth.lean`** (500+ lines): Supporting lemmas on p-adic valuation, Taylor remainder bounds, Hensel derivative preservation. 20+ theorems.

- **`Cryptography/PadicCryptoHardness.lean`** (500+ lines): p-adic SVP valuation depth bounds, Hensel code minimum distance, post-quantum security reductions. 15+ theorems.

- **`EML/UltrametricCertifiedRobustness.lean`** (500+ lines): Ultrametric Lipschitz composition for neural networks, certified robustness radii in p-adic feature spaces. 15+ theorems.

Every theorem must use **diverse tactics** (induction for hierarchy theorems, by_contra for lower bounds, omega/linarith for quantitative bounds, rcases for existential witnesses, field_simp for valuation computations). **ZERO sorries** in the final output. Every theorem name must be inventive and every doc comment must explicitly state which domains it bridges.

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Open the field of non-Archimedean computation theory by proving three foundational theorems that establish how the ultrametric inequality fundamentally transforms algorithmic complexity. (1) Ultrametric Locality Theorem: p-adic addition and multiplication have constant valuation depth because the ultrametric inequality |a+b|_p ≤ max(|a|_p, |b|_p) eliminates carry propagation—unlike classical arithmetic where carries propagate O(log n) digits. Formalize valuation depth as a complexity measure and prove v_depth(a+b) = max(v_depth(a), v_depth(b)) + 1, giving O(1) vs O(log n) speedup. (2) Valuation Depth Hierarchy Theorem: Define VAL_k as functions f: ℤ_p^n → ℤ_p computable with valuation depth ≤ k. Prove VAL_k ⊊ VAL_{k+1} for all k by constructing witness functions based on Hensel lifting iterations—each additional valuation depth level enables exactly one more Newton–Hensel refinement step, and p-adic root-finding problems separate the hierarchy. (3) Hensel Speedup Theorem: p-adic Newton's method (Hensel's lemma) achieves quadratic convergence in valuation depth: if x_0 satisfies f(x_0) ≡ 0 mod p, then x_n satisfies f(x_n) ≡ 0 mod p^{2^n}, giving exponential convergence in the ultrametric topology. Prove this yields a certified algorithm for p-adic root finding that computes n correct p-adic digits in O(log n) valuation steps, exponentially faster than any classical root-finding method. This creates the first bridge between Algebra (4487 declarations: p-adic numbers, valuations, Hensel's lemma infrastructure) and Computation (941 declarations: algorithm analysis, complexity measures), opening an entirely new field with applications to p-adic cryptography, algorithmic number theory, and error-correcting codes over ultrametric spaces.

            ### Precise Mathematical Framing
            Let ℤ_p denote the p-adic integers with valuation v_p : ℤ_p → ℤ∪{∞} and ultrametric |·|_p. Define valuation depth of a computation as the minimum k such that the k-th output digit depends only on the first k input digits. Theorem 1 (Locality): ∀a b ∈ ℤ_p, v_depth(a + b) = max(v_depth(a), v_depth(b)) + 1 ∧ v_depth(a · b) ≤ max(v_depth(a), v_depth(b)) + 1. Theorem 2 (Hierarchy): ∀k ≥ 1, ∃f_k : ℤ_p → ℤ_p such that f_k ∈ VAL_{k+1} \ VAL_k, witnessed by f_k(x) = x^{p^k} mod p^{k+1} requiring k+1 Hensel iterations. Theorem 3 (Hensel Speedup): Given f ∈ ℤ_p[x] with f(α) ≡ 0 mod p and v_p(f'(α)) = 0, the Newton–Hensel iteration x_{n+1} = x_n - f(x_n)/f'(x_n) satisfies v_p(f(x_n)) ≥ 2^n, giving O(log n) valuation steps for n-digit precision versus Ω(n) for classical methods.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `grav_one_step_convergence` : theorem grav_one_step_convergence {X : Type*} (O : X → X) (hO : IsGravOracle O) (x : X) :
     (file: Computation/Oracles/GravityOracle.lean)
  2. `oracle_one_step_convergence` : theorem oracle_one_step_convergence {α : Type*} (O : UniversalOracle α)
     (file: Computation/Oracles/UniversalOracleTeam.lean)
  3. `hensel_convergence_rate` : theorem hensel_convergence_rate (j : ℕ) :
     (file: Computation/Factoring/FutureResearchTheorems.lean)
  4. `one_idempotent_mod` : theorem one_idempotent_mod (n : ℕ) [NeZero n] : IsIdempotentMod n 1 := by
     (file: Computation/Oracles/AlgorithmicUniversalOracle.lean)
  5. `quadratic_speedup_ratio` : theorem quadratic_speedup_ratio (N : ℕ) (hN : 1 < N) :
     (file: Computation/Oracles/MetaOracleFiveQuestions.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: tropical_cryptography_breakthrough_bridge, Tropical Central Limit Theorem: Gumbel Attraction, Max-Plus Stein Method, and Berry-Esseen Convergence Bounds, Tropical Quantum Mechanics: Maslov Dequantization, Tropical Born Rule, Max-Plus Unitary Collapse, and Entanglement Detection


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - Detailed proofs and explanations

            3. **DISCUSSION.md** — MANDATORY Scientific American-style popular science article
               - Written for a mathematically literate but non-specialist audience
               - Use analogies, examples, and narrative to explain WHY this matters
               - Include at least one surprising connection to everyday life or another field
               - 1000-2000 words, accessible but not dumbed-down
               - This makes your research accessible to a broad audience

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables,
                 what unexpected connections it reveals
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale (1 = one clever lemma, 5 = multi-theorem development)

               ## Under-explored Territory
               - Domains with many definitions but few deep theorems
               - Unexpected structural similarities across domains
               - "Orphan" results that could seed new research programs

               ## Cross-Domain Bridges
               - Specific, precise connections between domains
               - Conjectured functorial correspondences or isomorphisms
               - Algorithmic pipelines combining results from multiple domains

               ## Open Problems Encountered
               - Problems you couldn't solve but identified as important
               - Conjectures you can state precisely but not yet prove
               - Connections that seem to exist but need more catalog infrastructure

            5. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            6. **diagram.svg** — visualization of key mathematical structures

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


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

Research domain: Computation
Research mode: formalize
