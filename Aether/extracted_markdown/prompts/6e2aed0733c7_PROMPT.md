## Research Task: EML Barron-type quantitative universal approximation with explicit width-rate tradeoff for finite activation algebras

Research Mode: PROVE

Develop a quantitative sparsification theory inside the existing EML approximation framework, not merely another density theorem. The goal is to isolate a structurally defined “atomic” subclass of the EML algebra and prove that bounded atomic variation implies explicit finite-width approximation rates. The minimal target is a Maurey-type \(O(W^{-1/2})\) sup-norm rate for uniformly bounded atoms; the stronger target is an \(O(W^{-1})\) rate under an additional greedy-selection hypothesis formalized as a one-step norm-reduction lemma. This should be set up so that the already established quantitative Stone–Weierstrass machinery can be composed with the new Barron-width theorem to yield a two-stage universal approximation statement for arbitrary continuous functions.

### Concrete setup to formalize

Work on a compact domain represented concretely enough to use the sup norm without topological overhead. A good default is a finite sample-space model first, where \(K = \mathrm{Fin}\ n\) and functions are `Fin n → ℝ`; this already captures the atomic sparsification mechanism and gives exact sup-norm statements. If the existing EML development already has a concrete compact space object with `‖f‖ = sSup {‖f x‖ | x}`, you may generalize afterward, but the finite-domain theorem should come first because it admits complete Lean proofs with `Finset` combinatorics.

Define an atomic family `G : Finset (X → ℝ)` or, more flexibly, a predicate `IsAtom : (X → ℝ) → Prop` together with a uniform bound
```lean
def AtomBound (B : ℝ) (IsAtom : (X → ℝ) → Prop) : Prop :=
  ∀ g, IsAtom g → ∀ x, |g x| ≤ B
```
and finite signed combinations with ℓ¹-budget:
```lean
def l1_weight (s : Finset ι) (a : ι → ℝ) : ℝ :=
  ∑ i in s, |a i|

def atomicCombination (s : Finset ι) (a : ι → ℝ) (g : ι → X → ℝ) : X → ℝ :=
  fun x => ∑ i in s, a i * g i x
```

For a finite-domain sup norm, use
```lean
def supNorm {n : ℕ} (f : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' (by simp) (fun x => |f x|)
```
or an equivalent existing `‖·‖∞` definition if already present.

Then define the finite Barron hull:
```lean
def HasAtomicRepresentation
    {X : Type} [Fintype X] [DecidableEq X]
    (IsAtom : (X → ℝ) → Prop) (B M : ℝ) (f : X → ℝ) : Prop :=
  ∃ (ι : Type) (_ : Fintype ι) (_ : DecidableEq ι)
    (s : Finset ι) (a : ι → ℝ) (g : ι → X → ℝ),
    (∀ i ∈ s, IsAtom (g i)) ∧
    (∑ i in s, |a i|) ≤ M ∧
    f = fun x => ∑ i in s, a i * g i x
```
This “finite Barron hull” is enough for the first theorem and avoids having to formalize closure/completion immediately. After the finite theorem is done, a closure-based extension can be stated separately:
```lean
def InBarronClosure ... : Prop := ∃ᶠ? -- or metric closure if convenient
```
but do not let this block the main result.

### Primary theorem: finite atomic sparsification with \(O(W^{-1/2})\) rate

A precise Lean target on a finite domain is:

```lean
theorem eml_atomic_maurey_sup
    {X : Type} [Fintype X] [DecidableEq X]
    (IsAtom : (X → ℝ) → Prop) (B M : ℝ)
    (hB : 0 ≤ B) (hM : 0 ≤ M)
    (hAtom : ∀ g, IsAtom g → ∀ x, |g x| ≤ B)
    (f : X → ℝ)
    (hf : HasAtomicRepresentation IsAtom B M f) :
    ∀ W : ℕ, 1 ≤ W →
      ∃ (ι : Type) (_ : Fintype ι) (_ : DecidableEq ι)
        (s : Finset ι) (a : ι → ℝ) (g : ι → X → ℝ),
        s.card ≤ W ∧
        (∀ i ∈ s, IsAtom (g i)) ∧
        (∑ i in s, |a i|) ≤ M ∧
        supNorm (f - fun x => ∑ i in s, a i * g i x)
          ≤ (2 * B * M) / Real.sqrt W := by
  ...
```

If subtraction of functions needs pointwise notation, use
```lean
supNorm (fun x => f x - ∑ i in s, a i * g i x)
```
instead.

A more canonical convex-average formulation may be easier to prove first. Normalize coefficients by total variation \(L = \sum |a_i|\), write
\[
f = L \sum_i p_i \sigma_i g_i,\qquad p_i = |a_i|/L,\ \sigma_i = \operatorname{sign}(a_i),
\]
and sample/average \(W\) atoms from the signed atomic set. Then prove existence of a multiset average with bounded expected squared error, and convert to a deterministic witness by finite expectation. This is the standard Maurey argument specialized to finite-dimensional \(\ell_\infty^n\).

A cleaner intermediate theorem is:

```lean
theorem eml_atomic_average_exists
    {X : Type} [Fintype X] [DecidableEq X]
    (B L : ℝ) (hB : 0 ≤ B) (hL : 0 ≤ L)
    (μ : ι → ℝ) (g : ι → X → ℝ) (s : Finset ι)
    (hμ_nonneg : ∀ i ∈ s, 0 ≤ μ i)
    (hμ_sum : ∑ i in s, μ i = 1)
    (hg : ∀ i ∈ s, ∀ x, |g i x| ≤ B) :
    ∀ W : ℕ, 1 ≤ W →
      ∃ (t : Fin W → ι),
        supNorm (fun x =>
          L * (∑ i in s, μ i * g i x) -
          L / W * ∑ j : Fin W, g (t j) x)
        ≤ (2 * B * L) / Real.sqrt W := by
  ...
```

Once this is proved, the signed-coefficient theorem follows by absorbing signs into the atom family:
```lean
g' i x = Real.sign (a i) * g i x
```
and checking the same uniform bound.

### Stronger theorem: \(O(W^{-1})\) under a one-step greedy reduction axiom

If you can formalize a greedy norm-reduction lemma already latent in the EML algebra machinery, add a stronger theorem. Package the hypothesis as an abstract axiom on the atomic family rather than hard-coding a difficult selection procedure:

```lean
def HasGreedyStep
    {X : Type} [Fintype X] [DecidableEq X]
    (IsAtom : (X → ℝ) → Prop) (C : ℝ) : Prop :=
  ∀ (r : X → ℝ) (R : ℝ),
    0 ≤ R →
    supNorm r ≤ R →
    ∃ g, IsAtom g ∧
      supNorm (fun x => r x - (R / C) * g x) ≤ R * (1 - 1 / C)
```

Then prove:

```lean
theorem eml_atomic_greedy_rate
    {X : Type} [Fintype X] [DecidableEq X]
    (IsAtom : (X → ℝ) → Prop) (B M C : ℝ)
    (hB : 0 ≤ B) (hM : 0 ≤ M) (hC : 1 ≤ C)
    (hAtom : ∀ g, IsAtom g → ∀ x, |g x| ≤ B)
    (hGreedy : HasGreedyStep IsAtom C)
    (f : X → ℝ)
    (hf : HasAtomicRepresentation IsAtom B M f) :
    ∀ W : ℕ, 1 ≤ W →
      ∃ (ι : Type) (_ : Fintype ι) (_ : DecidableEq ι)
        (s : Finset ι) (a : ι → ℝ) (g : ι → X → ℝ),
        s.card ≤ W ∧
        (∀ i ∈ s, IsAtom (g i)) ∧
        supNorm (fun x => f x - ∑ i in s, a i * g i x) ≤ (C * M) / W := by
  ...
```

This theorem is valuable even if `HasGreedyStep` is left as a reusable interface and instantiated later for concrete EML generators.

### Two-stage theorem: quantitative universal approximation by Stone–Weierstrass + sparsification

After the atomic theorem is established, compose it with the existing quantitative Stone–Weierstrass result. The intended structure is:

1. Quantitative Stone–Weierstrass produces an algebraic approximant `p` to `f` with explicit sup-norm error `ε₁(N)` and a representation complexity bound `A(N)`.
2. Convert that algebraic approximant into an atomic representation theorem:
   ```lean
   theorem eml_algebraic_implies_atomic
      ... :
      IsAlgebraicApproximant p degreeBound →
      HasAtomicRepresentation IsAtom B (A degreeBound) p
   ```
3. Apply the Maurey/greedy theorem to `p` with width `W`, producing `pW` and error `ε₂(W)`.
4. Conclude by triangle inequality:
   \[
   \|f - p_W\|_\infty \le \|f-p\|_\infty + \|p-p_W\|_\infty.
   \]

A precise abstract statement should look like:

```lean
theorem eml_two_stage_universal_approx
    {X : Type} [Fintype X] [DecidableEq X]
    (IsAtom : (X → ℝ) → Prop)
    (B : ℝ) (stoneRate barronBudget : ℕ → ℝ)
    (hB : 0 ≤ B)
    (hAtom : ∀ g, IsAtom g → ∀ x, |g x| ≤ B)
    (hStone :
      ∀ f : X → ℝ, ∀ N : ℕ, 1 ≤ N →
        ∃ p : X → ℝ,
          supNorm (fun x => f x - p x) ≤ stoneRate N ∧
          HasAtomicRepresentation IsAtom B (barronBudget N) p) :
    ∀ (f : X → ℝ) (N W : ℕ), 1 ≤ N → 1 ≤ W →
      ∃ q : X → ℝ,
        supNorm (fun x => f x - q x)
          ≤ stoneRate N + (2 * B * barronBudget N) / Real.sqrt W := by
  ...
```

If the stronger greedy theorem is available, prove the sharper corollary
```lean
≤ stoneRate N + (C * barronBudget N) / W.
```

### Proof strategy hints

1. **Normalize a signed atomic representation into a convex combination.**  
   Given
   \[
   f = \sum_{i \in s} a_i g_i,\qquad \sum |a_i| \le M,
   \]
   define \(L = \sum |a_i|\), \(p_i = |a_i|/L\) when \(L \neq 0\), and \(h_i = \operatorname{sign}(a_i) g_i\). Then
   \[
   f = L \sum_i p_i h_i,
   \]
   with each \(h_i\) still uniformly bounded by \(B\). In Lean, split on `hL : L = 0`; the zero case is trivial since all coefficients vanish by positivity of absolute values.

2. **Prove the averaging lemma on the finite domain coordinatewise.**  
   For \(X = \mathrm{Fin}\ n\), the target function space is \(\mathbb R^n\). Let random variables \(Y_j\) take values in the finite set of atoms according to \(p_i\). The empirical average approximates the mean. Since each coordinate is bounded by \(B\), one has
   \[
   \mathbb E |(\mu - \bar Y_W)(x)|^2 \le \frac{4B^2}{W}.
   \]
   Summing over finitely many coordinates gives an expectation bound in \(\ell_2\), and then use
   \[
   \|v\|_\infty \le \|v\|_2.
   \]
   In Lean, this may be easier than a direct sup-norm probabilistic argument. Because the domain is finite, you can avoid measure theory entirely by averaging over all maps `Fin W → ι` with uniform counting measure; expectation is just a finite sum over `Fintype (Fin W → ι)`.

3. **Derive existence from average error.**  
   Once you prove that the average over all samples `t : Fin W → ι` of a nonnegative quantity is bounded by `R`, conclude that there exists some `t` attaining at most `R`. This is a standard `Finset.exists_le_of_average_le` style argument; if no exact lemma exists, prove a short auxiliary combinatorial lemma for finite sums of nonnegative reals.

4. **Convert empirical averages into width-\(W\) networks.**  
   If `t : Fin W → ι`, define grouped coefficients by counting multiplicities:
   ```lean
   a' i = L * ((Finset.univ.filter fun j : Fin W => t j = i).card : ℝ) / W
   ```
   or simply keep the representation indexed by `Fin W`, which automatically has cardinality `W`. The latter is often Lean-friendlier:
   ```lean
   g' : Fin W → X → ℝ := fun j => h (t j)
   a' : Fin W → ℝ := fun _ => L / W
   ```
   Then the approximant is exactly `fun x => ∑ j : Fin W, a' j * g' j x`.

5. **For the two-stage theorem, isolate all complexity transfer into one lemma.**  
   The hard bridge is not the triangle inequality but the statement that a Stone–Weierstrass approximant belongs to the atomic hull with explicit ℓ¹-budget. Formalize this as a reusable theorem from the EML algebra semantics:
   ```lean
   theorem eml_quantitative_stone_weierstrass_atomic_budget ...
   ```
   Even if the exact budget is not optimal, any explicit bound suffices to make the new theorem meaningful.

### Key auxiliary lemmas worth proving first

These are likely reusable and should be stated cleanly.

```lean
theorem supNorm_nonneg {n : ℕ} (f : Fin n → ℝ) : 0 ≤ supNorm f := by ...

theorem supNorm_le_of_pointwise
    {n : ℕ} {f : Fin n → ℝ} {R : ℝ}
    (h : ∀ x, |f x| ≤ R) :
    supNorm f ≤ R := by ...

theorem supNorm_add_le
    {n : ℕ} (f g : Fin n → ℝ) :
    supNorm (fun x => f x + g x) ≤ supNorm f + supNorm g := by ...

theorem supNorm_sub_le
    {n : ℕ} (f g : Fin n → ℝ) :
    supNorm (fun x => f x - g x) ≤ supNorm f + supNorm g := by ...

theorem supNorm_smul_le
    {n : ℕ} (c : ℝ) (f : Fin n → ℝ) :
    supNorm (fun x => c * f x) ≤ |c| * supNorm f := by ...

theorem supNorm_le_l2Norm
    {n : ℕ} (f : Fin n → ℝ) :
    supNorm f ≤ Real.sqrt (∑ x, (f x)^2) := by ...
```

For convex combinations of bounded atoms:
```lean
theorem supNorm_convex_combination_le
    {X : Type} [Fintype X] [DecidableEq X]
    (s : Finset ι) (μ : ι → ℝ) (g : ι → X → ℝ) (B : ℝ)
    (hμ_nonneg : ∀ i ∈ s, 0 ≤ μ i)
    (hμ_sum : ∑ i in s, μ i = 1)
    (hg : ∀ i ∈ s, ∀ x, |g i x| ≤ B) :
    supNorm (fun x => ∑ i in s, μ i * g i x) ≤ B := by ...
```

And the signed-normalization lemma:
```lean
theorem atomic_representation_as_convex
    {X : Type} [Fintype X] [DecidableEq X]
    (IsAtom : (X → ℝ) → Prop) (B : ℝ)
    (hAtom : ∀ g, IsAtom g → ∀ x, |g x| ≤ B)
    {ι : Type} [Fintype ι] [DecidableEq ι]
    (s : Finset ι) (a : ι → ℝ) (g : ι → X → ℝ)
    (hgAtom : ∀ i ∈ s, IsAtom (g i)) :
    ∃ L : ℝ, 0 ≤ L ∧ L = ∑ i in s, |a i| ∧
      ∃ μ : ι → ℝ, ∀ i ∈ s, 0 ≤ μ i := by
  ...
```
You need not force the full decomposition into one theorem; several smaller lemmas may be more manageable.

### Why this matters

This result upgrades the EML program from qualitative expressivity to quantitative complexity control. The existing Stone–Weierstrass theorems show that EML-generated algebras are dense; the present goal is to show that low atomic variation implies small-width realizations with explicit error bounds. That is the missing bridge between “can approximate” and “can approximate efficiently.” Even the finite-domain \(O(W^{-1/2})\) theorem is substantial: it gives a formal sparsification principle for EML models, turns algebraic generators into width-bounded approximants, and creates a reusable template for later continuous compact-space generalizations, Barron-space definitions, and eventual full universal approximation theorems with complexity estimates. The stronger \(O(W^{-1})\) version, if obtained under a greedy-step hypothesis, would further connect the EML algebra to nonlinear approximation theory and certified model compression.

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

Research domain: EML
Research mode: prove
