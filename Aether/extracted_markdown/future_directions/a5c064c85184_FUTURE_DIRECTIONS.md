# Future Directions for Prime-Spectral Rate–Distortion Theory

## 1. Variational Free-Energy Capacity Formula

**Goal**: Identify `codingNumber(ε)` with a variational formula involving spectral free energy.

Conjecture: For a prime spectrum with gap function `gap`, the coding number satisfies
```
codingNumber(ε) = min { |C| : C ⊆ spec, max_{x ∈ pairs} F(spec,x) - F(C,x) ≤ ε }
```
where `F(C,x) = sup_{ω ∈ C} gap(ω, x)` is the free-energy functional (max-plus tropical convex combination). This is already our definition, but the next step is to prove a **dual formula**:
```
codingNumber(ε) = max over partitions of spec into blocks B_i such that
                  max_{x} (sup_{B_i} gap - sup_{B_j} gap) > ε for i ≠ j
```
This would be a finite analog of the Shannon rate–distortion function.

## 2. Submodularity and (1 - 1/e) Greedy Approximation Guarantee

**Goal**: Prove that `totalDistortion(·)` is a submodular set function (or that negative total distortion is submodular), yielding the classical `(1 - 1/e)`-approximation guarantee for the greedy algorithm.

The key lemma would be:
```lean
theorem totalDistortion_submodular :
    ∀ C D : Finset (PrimeBetaState ι), C ⊆ D → D ⊆ spec →
    ∀ ω ∈ spec,
      marginalGain pairs D ω ≤ marginalGain pairs C ω
```
This diminishing-returns property, combined with the already-proved `greedyStep_best_single_insertion`, would give:
```
totalDistortion(greedy(k)) ≤ (1 - 1/e)^k · totalDistortion(∅)
```
The proof requires showing that `sup'` over a larger set gains less from adding a new element—a property of the max operation.

## 3. Semantic Shannon Theorem for Proof Semirings

**Goal**: Develop an information-theoretic framework where:
- **Entropy** = log₂(codingNumber(0)) = minimum bits to represent full separation
- **Rate** = log₂(codingNumber(ε)) as a function of distortion ε
- **Capacity** = maximum rate at which semantic information can be transmitted through a "proof channel" with bounded distortion

This would formalize the analogy: prime spectral states are "channel inputs," pairs are "messages," and the gap function is the "channel transition." The coding number then becomes the channel coding capacity at distortion level ε.

## 4. Tropicalization of the Distortion Functional

**Goal**: Interpret the entire theory in the tropical semiring (ℝ ∪ {-∞}, max, +).

The `fullGap` and `restrictedGap` are already max-plus operations. In the tropical framework:
- Codebooks become **tropical polytope vertices**
- Distortion becomes **tropical distance** between the full and restricted tropical convex hulls
- The optimal codebook problem becomes a **tropical facility location** problem

Formalizing this connection would link prime-spectral rate–distortion to tropical geometry and the Maslov dequantization of probability.

## 5. Algorithmic Countermodel Extraction from Optimal Codebooks

**Goal**: Given an optimal ε-codebook C, extract a minimal countermodel (witness of non-derivability) for any pair (a,b) with `fullGap(a,b) > ε`.

The approximate reconstruction theorem guarantees that `restrictedGap(C, x) ≥ fullGap(x) - ε`. So if `fullGap(x) > ε`, then `restrictedGap(C, x) > 0`, meaning some `ω ∈ C` has `gap(ω, x) > 0`. This `ω` is a compressed countermodel.

Formalize the extraction procedure:
```lean
def extractCountermodel (C : Finset (PrimeBetaState ι)) (x : Pair S)
    (h : 0 < restrictedGap gap C x) : PrimeBetaState ι := ...

theorem countermodel_separates : gap (extractCountermodel C x h) x > 0 := ...
```

This would provide a complete pipeline: compress the spectrum → find optimal codebook → extract minimal witnesses. It connects to automated theorem proving by reducing the search space for counterexamples.
