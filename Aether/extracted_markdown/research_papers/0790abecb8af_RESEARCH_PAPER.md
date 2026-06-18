# Ordinal-Valued Proof Refinement Systems: Well-Foundedness, Fixed Points, and Spectral Gaps

## Abstract

We introduce a mathematical framework for studying how proofs improve over time. A *refinement system* pairs a type of proof objects with a complexity measure valued in a well-ordered type, together with a refinement relation that preserves an equivalence relation (proofs of the same theorem) while strictly decreasing complexity. We establish four main results: (1) the refinement relation is well-founded, guaranteeing termination of all simplification processes; (2) every proof has a minimal descendant under refinement; (3) every *strict optimizer* (a function that strictly decreases complexity on non-fixed-points) converges to a fixed point when iterated; and (4) for ℕ-valued systems, the length of any refinement chain from a proof of complexity *n* is at most *n*. We introduce *refinement spectra* and prove that spectral gaps exist. We define *refinement algebras* with subadditive composition and prove a compositional optimization bound. All results are formalized in Lean 4 with complete machine-checked proofs.

## 1. Introduction

The observation that proofs can be simplified — that a long, convoluted argument can often be replaced by a shorter, more elegant one — is as old as mathematics itself. Yet the mathematical study of *how* proofs simplify, and what universal laws govern the simplification process, has received relatively little formal attention.

This paper introduces **proof refinement systems**, a framework that abstracts the essential features of proof optimization into a clean algebraic structure. The key ingredients are:

1. A type `P` of proof objects,
2. A well-ordered type `α` serving as the complexity codomain,
3. A complexity measure `c : P → α`,
4. An equivalence relation `≡` on `P` (capturing "proofs of the same theorem"),
5. A refinement relation `⊏` such that `p ⊏ q` implies `p ≡ q` and `c(p) < c(q)`.

The well-ordering of `α` is the crucial structural assumption. It ensures that simplification must terminate — there are no infinite descending chains of ever-simpler proofs. This single axiom generates a surprisingly rich theory.

### 1.1 Related Work

The framework connects to several established areas:

- **Term rewriting systems** [Baader & Nipkow, 1998]: Our refinement relation generalizes the rewriting relation, with the complexity measure providing a termination argument.
- **Program optimization** [Aho et al., 2006]: Compiler optimization passes are instances of our strict optimizers.
- **Well-quasi-ordering theory** [Kruskal, 1960]: Our well-foundedness results are special cases of the general theory of well-founded relations.
- **Proof complexity** [Cook & Reckhow, 1979]: The refinement spectrum connects to the study of proof lengths across proof systems.
- **Kolmogorov complexity** [Li & Vitányi, 2008]: The minimal element in a refinement spectrum is analogous to Kolmogorov complexity — the length of the shortest description.

### 1.2 Contributions

Our main contributions are:

1. **Definition of refinement systems** with well-ordered complexity (Section 2).
2. **Well-foundedness theorem**: the refinement relation inherits well-foundedness from the complexity codomain (Theorem 3.1).
3. **Existence of minimal proofs** under refinement (Theorem 3.2).
4. **Fixed-Point Theorem**: every strict optimizer converges when iterated (Theorem 4.1).
5. **Chain length bound**: quantitative bounds for ℕ-valued systems (Theorem 5.1).
6. **Spectral gap existence**: refinement spectra can have gaps (Theorem 6.1).
7. **Refinement algebras**: compositional optimization bounds (Section 7).
8. **Complete formalization** in Lean 4 with machine-checked proofs.

## 2. Definitions

### 2.1 Refinement Systems

**Definition 2.1** (Refinement System). A *refinement system* is a tuple `(P, α, c, ≡, ⊏)` where:
- `P` is a type (the proof objects),
- `(α, <)` is a well-ordered type,
- `c : P → α` is the complexity measure,
- `≡` is an equivalence relation on `P`,
- `⊏` is a binary relation on `P` (refinement) satisfying:
  - *Equivalence preservation*: `p ⊏ q ⟹ p ≡ q`,
  - *Strict decrease*: `p ⊏ q ⟹ c(p) < c(q)`.

**Definition 2.2** (Minimal Proof). A proof `p` is *minimal* if there is no `q` with `q ⊏ p`.

**Definition 2.3** (Refinement Spectrum). The *refinement spectrum* of a proof `p` is:
```
Spec(p) = { c(q) | q ≡ p }
```
The set of all complexity values achievable by proofs equivalent to `p`.

### 2.2 Strict Optimizers

**Definition 2.4** (Strict Optimizer). A *strict optimizer* for a refinement system is a function `opt : P → P` satisfying:
- *Equivalence preservation*: `p ≡ opt(p)` for all `p`,
- *Strict decrease on non-fixed-points*: if `opt(p) ≠ p`, then `c(opt(p)) < c(p)`.

**Definition 2.5** (Fixed Point). A proof `p` is a *fixed point* of optimizer `opt` if `opt(p) = p`.

### 2.3 Refinement Algebras

**Definition 2.6** (Refinement Algebra). A *refinement algebra* is a refinement system `(P, α, c, ≡, ⊏)` equipped with a composition operation `∘ : P × P → P` satisfying:
- *Compatibility*: if `p₁ ≡ q₁` and `p₂ ≡ q₂`, then `p₁ ∘ p₂ ≡ q₁ ∘ q₂`,
- *Subadditivity*: `c(p ∘ q) ≤ c(p) + c(q)`.

## 3. Well-Foundedness and Minimal Proofs

### Theorem 3.1 (Well-Foundedness of Refinement)

*The refinement relation of any refinement system is well-founded.*

**Proof sketch.** We show that the refinement relation is a subrelation of `InvImage(c, <)`, which is well-founded since `<` is well-founded on `α`. Specifically, if `p ⊏ q`, then `c(p) < c(q)` by the strict decrease axiom. Since `α` is well-ordered, there is no infinite descending chain `... ⊏ p₂ ⊏ p₁ ⊏ p₀`, as this would yield an infinite descending chain `... < c(p₂) < c(p₁) < c(p₀)` in `α`. □

This proof uses the standard technique of transferring well-foundedness via inverse image. The formal proof uses `WellFounded.wellFounded_iff_has_min` to reformulate well-foundedness as the existence of minimal elements in non-empty sets, then constructs the minimal element in the image under `c`.

### Theorem 3.2 (Existence of Minimal Proofs)

*For every proof `p` in a refinement system, there exists a minimal proof `q` reachable from `p` via a finite refinement chain.*

**Proof sketch.** Apply Theorem 3.1 to the set of proofs reachable from `p` via refinement chains. This set is non-empty (it contains `p` itself). By well-foundedness, it has a minimal element `q` — a proof from which no further refinement is possible. □

### Theorem 3.3 (Nonemptiness of Spectra)

*The refinement spectrum `Spec(p)` is nonempty for every proof `p`.*

**Proof.** We have `c(p) ∈ Spec(p)` since `p ≡ p` by reflexivity of equivalence. □

## 4. The Fixed-Point Theorem

### Theorem 4.1 (Optimizer Convergence)

*Let `opt` be a strict optimizer for a refinement system. For every proof `p`, the sequence `p, opt(p), opt²(p), ...` stabilizes: there exists `n ∈ ℕ` such that `optⁿ⁺¹(p) = optⁿ(p)`.*

**Proof sketch.** By contradiction. Suppose the sequence never stabilizes: `optⁿ⁺¹(p) ≠ optⁿ(p)` for all `n`. By the strict decrease property, `c(optⁿ⁺¹(p)) < c(optⁿ(p))` for all `n`. This gives an infinite strictly decreasing sequence `c(p) > c(opt(p)) > c(opt²(p)) > ...` in the well-ordered type `α`, contradicting well-foundedness.

The formal proof constructs the range `{c(optⁿ(p)) | n ∈ ℕ}` as a nonempty subset of `α` and derives a contradiction from the fact that its purported minimal element admits a strictly smaller element in the range. □

### Theorem 4.2 (Stabilization Gives Fixed Points)

*If `optⁿ⁺¹(p) = optⁿ(p)`, then `optⁿ(p)` is a fixed point of `opt`.*

**Proof.** By definition of iteration, `optⁿ⁺¹(p) = opt(optⁿ(p))`. The hypothesis gives `opt(optⁿ(p)) = optⁿ(p)`, which is exactly the fixed-point condition. □

### Theorem 4.3 (Fixed-Point Theorem)

*Every strict optimizer has a fixed point equivalent to any given starting proof.*

**Proof.** Combine Theorem 4.1 (to obtain the stabilization index `n`) and Theorem 4.2 (to verify the fixed-point property). For equivalence: by induction on `k`, `p ≡ optᵏ(p)` for all `k`, since `opt` preserves equivalence and `≡` is transitive. □

### Corollary 4.4 (Composition Preserves Equivalence)

*Composing two strict optimizers preserves equivalence: for any optimizers `opt₁, opt₂` and proof `p`, we have `p ≡ opt₁(opt₂(p))`.*

This follows from transitivity of equivalence: `p ≡ opt₂(p) ≡ opt₁(opt₂(p))`.

## 5. Quantitative Bounds

### Theorem 5.1 (Chain Length Bound for ℕ-Valued Systems)

*In a ℕ-valued refinement system, for any refinement chain `p₀, p₁, p₂, ...` where `pₖ₊₁ ⊏ pₖ` for all `k`, we have `c(pₖ) + k ≤ c(p₀)` for all `k`.*

**Proof.** By induction on `k`. The base case is trivial. For the inductive step, from `pₖ₊₁ ⊏ pₖ` we get `c(pₖ₊₁) < c(pₖ)`, i.e., `c(pₖ₊₁) + 1 ≤ c(pₖ)` since we're in ℕ. Adding the inductive hypothesis `c(pₖ) + k ≤ c(p₀)` gives `c(pₖ₊₁) + (k+1) ≤ c(p₀)`. □

**Corollary 5.2.** The maximum length of a refinement chain from a proof of complexity `n` is exactly `n`. This is achieved when `c(pₖ) = n - k` for all `k ≤ n`.

## 6. Spectral Gaps

### Definition 6.1 (Spectral Gap)

A refinement system has a *spectral gap* at proof `p` if there exist `a, a+2 ∈ Spec(p)` with `a+1 ∉ Spec(p)`.

### Theorem 6.1 (Spectral Gaps Exist)

*There exists a ℕ-valued refinement system with a spectral gap.*

**Proof.** Construct `P = ℕ` with `c = id`, equivalence `p ≡ q ⟺ p mod 2 = q mod 2`, and refinement `p ⊏ q ⟺ p + 2 = q ∧ p mod 2 = q mod 2`. This is a valid refinement system: refinement preserves parity (hence equivalence) and strictly decreases complexity. The spectrum of the proof `0` is `{0, 2, 4, ...}` — all even numbers. We have `0 ∈ Spec(0)` and `2 ∈ Spec(0)` but `1 ∉ Spec(0)` (since 1 has odd parity). Thus there is a spectral gap at `a = 0`. □

### Discussion

Spectral gaps have significant implications for proof search:

1. **Local search fails at gaps**: An optimizer that decreases complexity by 1 at each step cannot cross a spectral gap. It will get stuck at a local minimum.
2. **Gap width measures difficulty**: Wider gaps require more radical restructuring to cross.
3. **Connection to proof complexity**: Spectral gaps in natural proof systems would imply that some theorems have proofs of vastly different lengths with no intermediate-length proofs.

## 7. Refinement Algebras

### Theorem 7.1 (Compositional Optimization Bound)

*In a ℕ-valued refinement algebra, if `opt` is a strict optimizer, then*
```
c(opt(p) ∘ opt(q)) ≤ c(p) + c(q)
```

**Proof.** By subadditivity, `c(opt(p) ∘ opt(q)) ≤ c(opt(p)) + c(opt(q))`. For each component, either `opt(p) = p` (complexity unchanged) or `c(opt(p)) < c(p)` (strict decrease). In either case, `c(opt(p)) ≤ c(p)`. Similarly for `q`. The result follows by `≤`-transitivity and monotonicity of addition. □

This theorem validates a divide-and-conquer optimization strategy: optimize components independently, then compose. The composed result is guaranteed to have complexity at most the sum of the original component complexities.

## 8. Discussion

### 8.1 Generality of the Framework

The framework is parametric in the complexity codomain `α`. Key instantiations include:

| Codomain | Interpretation | Chain Length |
|----------|---------------|-------------|
| ℕ | Finite proof complexity (line count, symbol count) | Finite, bounded by `c(p)` |
| Ordinal | Transfinite complexity (proof-theoretic ordinals) | Transfinite, bounded by `c(p)` |
| ℕ × ℕ (lex) | Two-dimensional complexity (length + depth) | Finite, non-trivially bounded |

### 8.2 Connections to Circuit Complexity

Proofs and Boolean circuits share structural parallels:
- Both have natural-number complexity measures (proof length / circuit size).
- Both admit composition with subadditivity.
- Both exhibit well-foundedness of simplification.
- The spectral gap phenomenon parallels the gap between circuit size and depth.

A unified refinement framework for proofs and circuits could yield new lower bounds: a spectral gap in the proof-circuit correspondence would imply that certain functions require circuits of size that cannot be achieved by any simple transformation from the best known construction.

### 8.3 Connections to Kolmogorov Complexity

The infimum of the refinement spectrum — the complexity of the simplest equivalent proof — is analogous to Kolmogorov complexity. Like Kolmogorov complexity, it is:
- Well-defined (as the infimum of a well-ordered non-empty set),
- Invariant under the choice of starting proof (depending only on the equivalence class),
- Generally uncomputable (finding the minimal proof may be undecidable).

Unlike Kolmogorov complexity, the refinement spectrum contains more information than a single number. Its structure (gaps, density, clustering) encodes properties of the proof system itself.

## 9. Future Work

1. **Ordinal-valued refinement depth**: Define a rank function for proofs using the well-founded recursion rank, enabling measurement of transfinite refinement chain lengths.
2. **Optimizer comparison**: Develop a theory of when one optimizer dominates another, leading to a partial order on optimization strategies.
3. **Effective refinement**: Identify classes of refinement systems where minimal proofs are computable.
4. **Categorical refinement**: Formulate refinement systems as categories with a faithful functor to a well-ordered category.
5. **Spectral gap complexity**: Study the computational complexity of deciding whether a given refinement system has a spectral gap.

## References

1. Baader, F., & Nipkow, T. (1998). *Term Rewriting and All That*. Cambridge University Press.
2. Cook, S. A., & Reckhow, R. A. (1979). The relative efficiency of propositional proof systems. *Journal of Symbolic Logic*, 44(1), 36-50.
3. Kruskal, J. B. (1960). Well-quasi-ordering, the Tree Theorem, and Vazsonyi's conjecture. *Transactions of the AMS*, 95(2), 210-225.
4. Li, M., & Vitányi, P. (2008). *An Introduction to Kolmogorov Complexity and Its Applications*. Springer.
5. Aho, A. V., Lam, M. S., Sethi, R., & Ullman, J. D. (2006). *Compilers: Principles, Techniques, and Tools*. Pearson.
