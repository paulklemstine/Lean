## Research Task: Tropical Satake injectivity for GL₃ via min-plus Newton polytope reconstruction of dominant coweight support

Research Mode: PROVE

Create `Tropical/Langlands/GL3SatakeInjective.lean`.

Work with a concrete model of dominant GL₃ coweights as triples of naturals in weakly decreasing order. A good starting point is
```lean
def DomCoweightGL3 := {v : Fin 3 → ℕ // v 0 ≥ v 1 ∧ v 1 ≥ v 2}
```
or an equivalent structure with fields `a b c : ℕ` and proofs `a ≥ b`, `b ≥ c`. For tropical characters, use real dominant weights
```lean
def DomWeightGL3 := {x : Fin 3 → ℝ // x 0 ≥ x 1 ∧ x 1 ≥ x 2}
```
and define the pairing
```lean
def pairGL3 (x : DomWeightGL3) (λ : DomCoweightGL3) : ℝ :=
  ∑ i : Fin 3, (x.1 i) * (λ.1 i)
```
after coercing `ℕ` to `ℝ`.

Represent a finitely supported tropical Hecke function by
```lean
abbrev TropHeckeGL3 := DomCoweightGL3 → ℝ∞
```
together with a finite support hypothesis
```lean
def HasFiniteSupport (f : TropHeckeGL3) : Prop :=
  {λ | f λ ≠ ⊤}.Finite
```
or, if technically easier, package the data as a `Finset`-indexed coefficient function:
```lean
structure FinSuppTropHeckeGL3 where
  support : Finset DomCoweightGL3
  coeff   : DomCoweightGL3 → ℝ
  mem_support_iff : ∀ λ, λ ∈ support ↔ True -- replace by your preferred convention
```
The important point is that the tropical Satake transform should be a finite min:
```lean
def satakeGL3 (f : DomCoweightGL3 → ℝ∞) (s : Finset DomCoweightGL3)
    (hs : ∀ λ, f λ = ⊤ ↔ λ ∉ s) :
    DomWeightGL3 → ℝ :=
  fun χ => (s.inf' (by simpa using Finset.nonempty_of_ne_empty ?h)
    (fun λ => (f λ).toReal + pairGL3 χ λ))
```
You may choose a cleaner API, but the final theorem should quantify over a genuinely finite-support class so that all minima are attained.

### Main theorem to target

A precise injectivity statement worth formalizing is:
```lean
theorem satakeGL3_injective
    (f g : DomCoweightGL3 → ℝ∞)
    (hf : HasFiniteSupport f)
    (hg : HasFiniteSupport g)
    (hfinf : ∀ λ, f λ ≠ ⊥)
    (hginf : ∀ λ, g λ ≠ ⊥)
    (hEq : ∀ χ : DomWeightGL3, satakeGL3_of_finsupp f hf χ = satakeGL3_of_finsupp g hg χ) :
    f = g
```
If avoiding `ℝ∞` complications is materially simpler, prove the cleaner finite-support real-valued version first:
```lean
structure TropicalSeriesGL3 where
  support : Finset DomCoweightGL3
  coeff   : DomCoweightGL3 → ℝ
  coeff_outside : ∀ λ, λ ∉ support → coeff λ = 0

def satakeGL3 (F : TropicalSeriesGL3) (χ : DomWeightGL3) : ℝ :=
  (F.support.inf' (by
      classical
      by_cases h : F.support.Nonempty
      · simpa using h
      · -- exclude empty support in theorem statements
        sorry)
    (fun λ => F.coeff λ + pairGL3 χ λ))
```
and then establish:
```lean
theorem satakeGL3_injective_real
    {F G : TropicalSeriesGL3}
    (hF : F.support.Nonempty)
    (hG : G.support.Nonempty)
    (hEq : ∀ χ : DomWeightGL3, satakeGL3 F χ = satakeGL3 G χ) :
    F.coeff = G.coeff
```
A still more robust theorem, and probably the right one for the Newton-polytope argument, is support-and-coefficient reconstruction:
```lean
theorem satakeGL3_recovers_support_and_coeff
    {F G : TropicalSeriesGL3}
    (hF : F.support.Nonempty)
    (hG : G.support.Nonempty)
    (hEq : ∀ χ : DomWeightGL3, satakeGL3 F χ = satakeGL3 G χ) :
    F.support = G.support ∧ ∀ λ, F.coeff λ = G.coeff λ
```

### Geometric reformulation to prove first

Define the tropical Newton value function
```lean
def newtonLiftVal (F : TropicalSeriesGL3) (χ : DomWeightGL3) : ℝ :=
  F.support.inf' ?hne (fun λ => F.coeff λ + pairGL3 χ λ)
```
This is the min-plus support function of the lifted finite set
\[
\{(\lambda, t) : \lambda \in \operatorname{supp}(F),\ t = F(\lambda)\}.
\]
You do not need a full convex-geometry library formalization of epigraphs if that becomes heavy. What matters is the finite-dimensional exposed-point principle:

1. the value `satakeGL3 F χ` is the minimum of finitely many affine-linear functions in `χ`;
2. if one affine term is strictly smaller than all others at some `χ`, then the minimizer is unique and the value locally equals that affine term;
3. equality of the min-envelope for all `χ` forces equality of the uniquely exposed affine pieces;
4. every vertex of the lower Newton hull can be exposed by some dominant `χ`, provided the relevant normal lies in the dominant chamber.

Formalize this in finite-set language rather than abstract polytope language if that is more practical.

A key intermediate theorem should look like:
```lean
def IsUniqueMinimizerOn (F : TropicalSeriesGL3) (χ : DomWeightGL3) (λ : DomCoweightGL3) : Prop :=
  λ ∈ F.support ∧
  satakeGL3 F χ = F.coeff λ + pairGL3 χ λ ∧
  ∀ μ ∈ F.support, μ ≠ λ → F.coeff λ + pairGL3 χ λ < F.coeff μ + pairGL3 χ μ

theorem coeff_eq_of_unique_minimizer
    {F G : TropicalSeriesGL3} {χ : DomWeightGL3} {λ : DomCoweightGL3}
    (hEq : ∀ ξ : DomWeightGL3, satakeGL3 F ξ = satakeGL3 G ξ)
    (hFuniq : IsUniqueMinimizerOn F χ λ)
    (hGuniq : IsUniqueMinimizerOn G χ λ) :
    F.coeff λ = G.coeff λ
```
and, more importantly, a one-sided reconstruction theorem:
```lean
theorem exists_same_unique_minimizer_of_satake_eq
    {F G : TropicalSeriesGL3} {χ : DomWeightGL3} {λ : DomCoweightGL3}
    (hEq : ∀ ξ : DomWeightGL3, satakeGL3 F ξ = satakeGL3 G ξ)
    (hFuniq : IsUniqueMinimizerOn F χ λ) :
    λ ∈ G.support ∧ G.coeff λ = F.coeff λ
```
The proof idea is strict separation: if every term of `G` were strictly above `F.coeff λ + pairGL3 χ λ` at `χ`, then `satakeGL3 G χ` would be larger. If some different `μ ≠ λ` tied at `χ`, perturb `χ` within the dominant chamber along a direction that changes `pairGL3 · λ` and `pairGL3 · μ` differently while preserving the strict inequalities against all remaining support elements. Finite support makes this perturbation argument manageable.

### Concrete separation lemmas to establish

You need explicit dominant-chamber perturbation lemmas for distinct dominant coweights. Prove some version of:

```lean
theorem exists_dominant_separator_of_ne
    {λ μ : DomCoweightGL3} (hne : λ ≠ μ) :
    ∃ χ : DomWeightGL3, pairGL3 χ λ ≠ pairGL3 χ μ
```
A stronger and more useful version is:
```lean
theorem exists_strict_dominant_separator_of_ne
    {λ μ : DomCoweightGL3} (hne : λ ≠ μ) :
    ∃ χ : DomWeightGL3, pairGL3 χ λ < pairGL3 χ μ ∨ pairGL3 χ μ < pairGL3 χ λ
```
Because λ and μ are dominant triples, you can prove this by considering the first coordinate where they differ and choosing a rapidly decreasing dominant weight, for example values proportional to `(R^2, R, 1)` with `R` large. In Lean, an explicit fixed choice like `(4,2,1)` or `(9,3,1)` may already separate many pairs but not all; better is to define χ depending on λ and μ via lexicographic dominance:
```lean
χ = (M^2, M, 1)
```
for `M > max |λ_i - μ_i| + 1`. Then
\[
\langle χ, λ - μ\rangle
\]
has the sign of the first nonzero coordinate difference. This gives a very concrete finite-dimensional replacement for Hahn–Banach-style separation.

You will likely also need a perturbation lemma for finitely many inequalities:
```lean
theorem exists_dominant_perturbation_preserving_unique_min
    {F : TropicalSeriesGL3} {χ₀ : DomWeightGL3} {λ : DomCoweightGL3}
    (huniq : IsUniqueMinimizerOn F χ₀ λ) :
    ∃ ε > 0, ∀ δ : DomWeightGL3,
      ‖(δ : Fin 3 → ℝ) - χ₀.1‖ < ε →
      satakeGL3 F δ = F.coeff λ + pairGL3 δ λ
```
If norm-topology is too heavy, prove instead a combinatorial directional version:
```lean
theorem exists_direction_preserving_and_separating
    {F : TropicalSeriesGL3} {χ : DomWeightGL3} {λ μ : DomCoweightGL3}
    (huniq : IsUniqueMinimizerOn F χ λ)
    (hμ : μ ∈ F.support) (hne : μ ≠ λ) :
    ∃ v : DomWeightGL3,
      pairGL3 v λ < pairGL3 v μ ∧
      ∀ ν ∈ F.support, ν ≠ λ →
        F.coeff λ + pairGL3 χ λ + pairGL3 v λ
          < F.coeff ν + pairGL3 χ ν + pairGL3 v ν
```
This can be proved by taking a separator for λ against each competing ν and summing with sufficiently rapidly decaying positive coefficients, using finiteness of support.

### Dominance-order induction

To avoid hard convex-geometry infrastructure, implement the reconstruction as induction on the finite support ordered by a scalar height functional. A useful height is:
```lean
def cwHeight (λ : DomCoweightGL3) : ℕ := λ.1 0 + λ.1 1 + λ.1 2
```
or the lexicographic order on triples. Show that every nonempty finite support contains an exposed element for a suitable dominant χ. Then recover its coefficient, delete it, and continue.

A suitable deletion theorem:
```lean
def eraseCoeff (F : TropicalSeriesGL3) (λ : DomCoweightGL3) : TropicalSeriesGL3 := ...

theorem satake_eq_after_erasing_exposed
    {F G : TropicalSeriesGL3} {λ : DomCoweightGL3}
    (hEq : ∀ χ, satakeGL3 F χ = satakeGL3 G χ)
    (hrec : ∀ χ, IsUniqueMinimizerOn F χ λ → λ ∈ G.support ∧ G.coeff λ = F.coeff λ) :
    ∀ χ, satakeGL3 (eraseCoeff F λ) χ = satakeGL3 (eraseCoeff G λ) χ
```
A cleaner approach is to first prove equality of all exposed coefficients, then use the fact that every support point of a finite lower hull becomes exposed after removing previously reconstructed lower faces. This is the “descend on the lower Newton polytope” part of the argument.

If full induction on lower hulls is too ambitious, it is still a strong theorem to prove injectivity under a genericity hypothesis:
```lean
def GenericSupport (F : TropicalSeriesGL3) : Prop :=
  ∀ λ ∈ F.support, ∃ χ : DomWeightGL3, IsUniqueMinimizerOn F χ λ

theorem satakeGL3_injective_of_generic
    {F G : TropicalSeriesGL3}
    (hGenF : GenericSupport F)
    (hGenG : GenericSupport G)
    (hEq : ∀ χ : DomWeightGL3, satakeGL3 F χ = satakeGL3 G χ) :
    F.coeff = G.coeff
```
But the preferred endpoint is the unconditional finite-support theorem.

### Suggested proof skeleton

1. **Finite minimum / piecewise-linear setup.**  
   Show `satakeGL3 F χ` is the minimum over `F.support` of affine maps `χ ↦ F.coeff λ + pairGL3 χ λ`. Establish attainment and basic inequalities:
   ```lean
   theorem satakeGL3_le_term (F) (χ) {λ} (hλ : λ ∈ F.support) :
     satakeGL3 F χ ≤ F.coeff λ + pairGL3 χ λ
   ```
   and if λ is the unique minimizer then equality holds.

2. **Strict separation of distinct coweights in the dominant chamber.**  
   Prove `exists_strict_dominant_separator_of_ne`. The key trick is weighted lexicographic separation by a dominant weight `(M^2, M, 1)` with `M` chosen from the coordinate differences. This is the rank-3 substitute for the easier GL₂ slope comparison.

3. **Recover exposed coefficients from equality of transforms.**  
   Suppose λ is a unique minimizer for `F` at χ. Use `hEq χ` to show `G` has some minimizer at χ with the same value. If it were always a different μ, perturb χ using the separator lemma to force a contradiction with pointwise equality of transforms in a nearby dominant direction. Conclude `λ ∈ G.support` and `G.coeff λ = F.coeff λ`.

4. **Induct on finite support / lower hull complexity.**  
   Remove a reconstructed exposed λ from both supports and show equality of the remaining transforms, or equivalently restrict to supports of strictly smaller cardinality after quotienting out the known affine piece. Since support is finite, this process terminates and yields coefficient equality on all λ.

5. **Extensionality.**  
   Finish with function extensionality:
   ```lean
   ext λ
   ```
   splitting into cases `λ ∈ support` / `λ ∉ support` if you use a packaged finite-support representation.

### Lean-specific advice

- Favor `Finset` formulations over abstract convex hulls. The Newton polytope language should guide the mathematics, but the formal proof can be entirely about minima of finitely many affine functions.
- If coercions from `ℕ` to `ℝ` become noisy, define
  ```lean
  def pairGL3NatReal (x : Fin 3 → ℝ) (λ : Fin 3 → ℕ) : ℝ := ...
  ```
  and keep the subtype wrappers only at the edges.
- You may want a lexicographic helper:
  ```lean
  def lexTriple (λ : DomCoweightGL3) : ℕ × ℕ × ℕ := ...
  ```
  together with a theorem that unequal dominant triples are separated by `(M^2, M, 1)`.
- If `ℝ∞` causes avoidable pain, prove the real-valued finite-support theorem first and then wrap it into a tropical-Hecke statement by interpreting “outside support” as `⊤`.

### Why this matters

This is the first genuinely higher-rank structural theorem in the tropical Satake direction. The verified GL₂ story only sees one-dimensional slope geometry; GL₃ forces true polyhedral behavior, exposed lower faces, and chamber-restricted separation. Proving injectivity from the min-plus transform shows that tropical Satake data retains the full coefficient-level Hecke information even in rank 2 root systems. That is exactly the kind of rigidity needed for a viable tropical Langlands program for `GL n`: before studying convolution faithfulness, representation-theoretic positivity, or tropical spectral decompositions, one must know the transform does not collapse distinct Hecke functions. Formalizing the GL₃ case via finite min-envelope reconstruction also sets up reusable infrastructure for higher-rank tropical Newton polytopes, which should feed directly into later work on tropical Hecke algebras and min-plus canonical bases.

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

Research domain: Tropical
Research mode: prove
