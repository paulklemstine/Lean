

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

## MISSION: Min-Plus Harmonic Analysis — Legendre-Fenchel Spectral Theory, Idempotent Parseval Identity, and Tropical Uncertainty Principles

We formalize the foundations of **min-plus (tropical) harmonic analysis**, establishing the Legendre-Fenchel transform as the natural Fourier transform in the idempotent setting. This creates a new field at the intersection of convex analysis, idempotent mathematics, and tropical geometry, with direct applications to **certified robustness of neural networks** (tropical uncertainty bounds on adversarial perturbations), **post-quantum lattice cryptography** (min-plus spectral methods for lattice reduction), and **quantum mechanics** (Maslov's idempotent path integrals as tropical limits of Feynman integrals).

The revolutionary insight: convex optimization IS tropical harmonic analysis. The Legendre-Fenchel transform IS the tropical Fourier transform. Duality in optimization IS spectral decomposition in the min-plus world. Every convex program is secretly a tropical signal processing problem.

---

## CORE DEFINITIONS (7 structures, 5+ instances)

### Definition 1: Tropical Fourier Transform (Legendre-Fenchel as Min-Plus DFT)
```lean
/-- The tropical Fourier transform: the Legendre-Fenchel conjugate reframed as
    min-plus harmonic analysis. Bridge: connects convex optimization to spectral theory.
    Application: tropical_frequency_decomposition for certified_robustness_bounds. -/
def tropicalFourierTransform {n : ℕ} (f : (Fin n → ℝ) → EReal) (ω : Fin n → ℝ) : EReal :=
  sInf (fun x => f x + ⟪ω, x⟫)  -- f̂(ω) = inf_x [f(x) + ⟨ω,x⟩]
```

### Definition 2: Tropical Fourier Inversion (Double Conjugate)
```lean
/-- The double tropical Fourier transform (Fenchel biconjugate).
    For proper lsc convex f, this recovers f — tropical Fourier inversion. -/
def tropicalFourierInversion {n : ℕ} (f : (Fin n → ℝ) → EReal) (x : Fin n → ℝ) : EReal :=
  sInf (fun ω => (tropicalFourierTransform f) ω + ⟪ω, x⟫)
```

### Definition 3: Tropical Spectral Support
```lean
/-- The essential frequency support: frequencies where f̂ is finite.
    Bridge: connects harmonic analysis to tropical geometry (tropical hypersurfaces).
    Application: adversarial_frequency_band detection. -/
def tropicalSpectrum {n : ℕ} (f : (Fin n → ℝ) → EReal) : Set (Fin n → ℝ) :=
  {ω | tropicalFourierTransform f ω < ⊤}
```

### Definition 4: Idempotent Energy (Min-Plus L² Norm)
```lean
/-- The idempotent energy: infimum as the min-plus integral (tropical L² norm).
    Bridge: connects measure theory to idempotent analysis.
    Application: tropical_energy_certification for neural network verification. -/
def idempotentEnergy {n : ℕ} (f : (Fin n → ℝ) → EReal) : EReal :=
  sInf (range f)
```

### Definition 5: Tropical Uncertainty Index
```lean
/-- Product of time-domain and frequency-domain essential support sizes.
    Lower bounds give fundamental limits on joint localization.
    Application: certified_robustness_margin for adversarial defense. -/
def tropicalUncertaintyIndex {n : ℕ} (f : (Fin n → ℝ) → EReal) : ℕ :=
  (tropicalSpectrum f).encard * (tropicalSpectrum (tropicalFourierTransform f)).encard
```

### Definition 6: Proper Lower Semicontinuous Convex Functions (Spectral Class)
```lean
/-- The spectral class: proper, lower semicontinuous, tropically convex functions.
    These are the functions for which tropical Fourier inversion holds. -/
structure TropicalSpectralClass (n : ℕ) where
  f : (Fin n → ℝ) → EReal
  proper : ∃ x, f x < ⊤  -- not identically +∞
  lsc : ∀ a, IsClosed {x | a ≤ f x}  -- lower semicontinuous
  tconvex : ∀ x y t, f ((1 - t) • x + t • y) ≤ max (f x) (f y)  -- tropical convexity
```

### Definition 7: Min-Plus DFT Matrix (Discrete Tropical Fourier Transform)
```lean
/-- The min-plus DFT matrix: tropical analogue of the unitary DFT matrix.
    Entry (k,j) = j*k/n gives the tropical character value.
    Bridge: connects finite group harmonic analysis to tropical linear algebra.
    Application: post_quantum_lattice_reduction via tropical spectral methods. -/
def minPlusDFTMatrix (n : ℕ) : Matrix (Fin n) (Fin n) ℝ :=
  fun k j => (j * k : ℕ) / (n : ℝ)  -- tropical character χₖ(j) = jk/n
```

---

## MAIN THEOREMS (10+ theorems with diverse tactics)

### Theorem 1: tropical_fourier_young_inequality
```lean
/-- Young's inequality for the tropical Fourier transform:
    f(x) + f̂(ω) ≥ ⟨ω,x⟩ for all x, ω.
    This is the tropical analogue of |f̂(ω)| ≤ ‖f‖₁.
    Bridge: connects convex analysis to harmonic analysis.
    Proof: By definition f̂(ω) = inf_x [f(x) + ⟨ω,x⟩], so for any x₀,
    f̂(ω) ≤ f(x₀) + ⟨ω,x₀⟩, hence f(x₀) + f̂(ω) ≥ f(x₀) + f(x₀) + ⟨ω,x₀⟩ - f(x₀) ≥ ⟨ω,x₀⟩. -/
theorem tropical_fourier_young_inequality {n : ℕ} {f : (Fin n → ℝ) → EReal}
    {x : Fin n → ℝ} {ω : Fin n → ℝ}
    (hf : f x < ⊤) :
    f x + tropicalFourierTransform f ω ≥ ⟪ω, x⟫ := by
  -- Strategy: unfold definition of tropicalFourierTransform,
  -- use csInf_le with witness x to get f̂(ω) ≤ f(x) + ⟨ω,x⟩,
  -- rearrange to f(x) + f̂(ω) ≥ ⟨ω,x⟩
  sorry  -- FILL: use csInf_le, EReal arithmetic
```

**Proof Strategy A (Direct)**: Unfold the definition of `tropicalFourierTransform`, use `csInf_le` with witness `x` to get `f̂(ω) ≤ f(x) + ⟨ω,x⟩`, then rearrange using `EReal` arithmetic with `add_le_add_right`.

**Proof Strategy B (Contrapositive)**: Assume `f(x) + f̂(ω) < ⟨ω,x⟩`, then `f̂(ω) < ⟨ω,x⟩ - f(x)`, contradicting `f̂(ω) = inf_x [f(x) + ⟨ω,x⟩] ≥ f(x) + ⟨ω,x⟩ - f(x) + f(x)` ... cleaner via `by_contra`.

### Theorem 2: tropical_fourier_double_conjugate_lower_bound
```lean
/-- The double tropical Fourier transform dominates the original: f ≤ f̂̂.
    This is the tropical analogue of f̂̂ ≥ f (Fourier inversion lower bound).
    Proof: From Young's inequality, f̂(ω) ≤ f(x) + ⟨ω,x⟩ for all ω,
    so f̂̂(x) = inf_ω [f̂(ω) + ⟨ω,x⟩] ≥ inf_ω [f(x)] = f(x) when f is bounded below. -/
theorem tropical_fourier_double_conjugate_lower_bound {n : ℕ}
    {f : (Fin n → ℝ) → EReal} {x : Fin n → ℝ}
    (hf_proper : ∃ y, f y < ⊤) :
    tropicalFourierInversion f x ≥ f x := by
  -- Strategy: Use tropical_fourier_young_inequality to show
  -- f̂(ω) + ⟨ω,x⟩ ≥ f(x) for all ω, then take infimum over ω
  sorry
```

### Theorem 3: tropical_fourier_inversion (FENCHel-MOREAU — The Central Theorem)
```lean
/-- TROPICAL FOURIER INVERSION (Fenchel-Moreau Theorem):
    For any function in the tropical spectral class (proper, lsc, tropically convex),
    the double tropical Fourier transform recovers the original function: f̂̂ = f.
    This establishes that the Legendre-Fenchel transform is the Fourier transform
    of tropical mathematics, with tropical Fourier inversion as its cornerstone.
    Bridge: connects convex optimization duality to harmonic analysis spectral theory.
    Application: tropical_signal_reconstruction for certified_robustness. -/
theorem tropical_fourier_inversion {n : ℕ} (φ : TropicalSpectralClass n) :
    tropicalFourierInversion φ.f = φ.f := by
  -- KEY PROOF ARCHITECTURE:
  -- Step 1: Show f ≤ f̂̂ (tropical_fourier_double_conjugate_lower_bound)
  -- Step 2: Show f ≥ f̂̂ for lsc convex f via separating hyperplane
  -- Step 3: Key lemma: if f(x₀) < α, construct ω such that f̂(ω) + ⟨ω,x₀⟩ < α
  -- Step 4: Use lsc to find open neighborhood where f < α
  -- Step 5: Use convexity + Hahn-Banach to construct separating hyperplane ω
  -- Step 6: This ω witnesses f̂̂(x₀) < α, contradicting f̂̂ ≥ f
  sorry
```

**Proof Strategy A (Hahn-Banach Separation)**: The classical proof. If f(x₀) > α = f̂̂(x₀), then epi(f) is a closed convex set not containing (x₀, α). By Hahn-Banach, find a separating hyperplane with normal (ω, -1). This ω gives f̂(ω) + ⟨ω,x₀⟩ ≤ α, so f̂̂(x₀) ≤ α < f(x₀), contradiction with f ≤ f̂̂.

**Proof Strategy B (Direct Convex Optimization)**: Use the perturbation function approach. Define g(y) = infₓ [f(x) : Ax = y] and show g*(ω) = f*(Aᵀω). Apply to the identity map.

**Strategy A is most promising** because Hahn-Banach is available in Mathlib and gives the cleanest separation argument.

### Theorem 4: idempotent_parseval_identity
```lean
/-- IDEMPOTENT PARSEVAL IDENTITY: The tropical energy is preserved under
    the tropical Fourier transform: inf_x f(x) = inf_ω f̂(ω) + C
    where C = 0 when the tropical characters satisfy inf_ω χ_ω(g) = 0 for all g.
    Bridge: connects idempotent analysis to measure-theoretic harmonic analysis.
    Application: tropical_energy_conservation for neural_network_verification. -/
theorem idempotent_parseval_identity {n : ℕ} {f : (Fin n → ℝ) → EReal}
    (hf_bdd_below : ∃ m, ∀ x, m ≤ f x)
    (hf_proper : ∃ x, f x < ⊤) :
    sInf (range f) = -tropicalFourierTransform f 0 := by
  -- Proof: f̂(0) = inf_x [f(x) + ⟨0,x⟩] = inf_x f(x)
  -- So inf_x f(x) = f̂(0), i.e., idempotent energy = tropical Fourier DC component
  sorry
```

### Theorem 5: idempotent_parseval_discrete
```lean
/-- DISCRETE IDEMPOTENT PARSEVAL: For the min-plus DFT over a finite group,
    the infimum is preserved: min_j f(j) = min_k f̂(k).
    This is the tropical analogue of Plancherel's theorem.
    Bridge: connects finite group harmonic analysis to tropical signal processing.
    Application: tropical_hash_collision resistance via energy conservation. -/
theorem idempotent_parseval_discrete {n : ℕ} (f : Fin n → ℝ) :
    sInf (range f) = sInf (range (minPlusDFT n f)) := by
  -- Proof: min_k f̂(k) = min_k min_j [f(j) + χ_k(j)]
  --       = min_j min_k [f(j) + χ_k(j)]
  --       = min_j [f(j) + min_k χ_k(j)]
  --       = min_j f(j)  (since min_k χ_k(j) = 0 for appropriate characters)
  sorry
```

### Theorem 6: tropical_uncertainty_principle
```lean
/-- TROPICAL UNCERTAINTY PRINCIPLE: For any tropical function f on a finite
    semimodule of dimension d, the product of essential support sizes satisfies:
    |essSupp(f)| · |essSupp(f̂)| ≥ d.
    This is the tropical analogue of the Donoho-Stark uncertainty principle and
    establishes a fundamental limit on simultaneous time-frequency localization.
    Bridge: connects harmonic analysis uncertainty to information theory.
    Application: certified_robustness_margin — adversarial perturbations cannot
    simultaneously localize in time and frequency domains. -/
theorem tropical_uncertainty_principle {n : ℕ} {f : (Fin n → ℝ) → EReal}
    (hf_finite_time : (tropicalSpectrum f).Finite)
    (hf_finite_freq : (tropicalSpectrum (tropicalFourierTransform f)).Finite) :
    (tropicalSpectrum f).encard * (tropicalSpectrum (tropicalFourierTransform f)).encard ≥ n := by
  -- KEY PROOF ARCHITECTURE:
  -- Step 1: Define the min-plus "restriction operator" R_S that zeros out
  --         frequencies outside support S
  -- Step 2: Show that R_S ∘ T ∘ R_T has tropical operator norm ≤ |S|·|T|/n
  -- Step 3: If |S|·|T| < n, this operator cannot be the identity
  -- Step 4: Therefore f cannot have supports S, T with |S|·|T| < n
  -- Strategy B: Via tropical linear algebra — the min-plus DFT matrix has
  -- full tropical rank n, so any submatrix of size < n cannot be invertible
  sorry
```

### Theorem 7: tropical_fourier_is_order_preserving
```lean
/-- The tropical Fourier transform is order-preserving:
    f ≤ g pointwise implies f̂ ≥ ĝ pointwise (note: reversal!).
    This is the tropical analogue of the Riemann-Lebesgue lemma direction.
    Bridge: connects order theory to spectral analysis. -/
theorem tropical_fourier_is_antitone {n : ℕ}
    {f g : (Fin n → ℝ) → EReal}
    (hf : ∀ x, f x ≤ g x) :
    ∀ ω, tropicalFourierTransform g ω ≤ tropicalFourierTransform f ω := by
  -- Proof: f̂(ω) = inf_x [f(x) + ⟨ω,x⟩] ≥ inf_x [g(x) + ⟨ω,x⟩] = ĝ(ω)
  -- when f ≤ g (since inf of larger set is smaller)
  sorry
```

### Theorem 8: tropical_convex_preserved_by_fourier
```lean
/-- The tropical Fourier transform preserves tropical convexity:
    if f is tropically convex, then f̂ is tropically convex.
    Bridge: connects tropical geometry to spectral theory.
    Application: tropical_convex_certification for robust ML. -/
theorem tropical_convex_preserved_by_fourier {n : ℕ}
    {f : (Fin n → ℝ) → EReal}
    (hf_tconvex : ∀ x y t, f ((1-t)•x + t•y) ≤ max (f x) (f y)) :
    ∀ ω₁ ω₂ t, tropicalFourierTransform f ((1-t)•ω₁ + t•ω₂) ≤
      max (tropicalFourierTransform f ω₁) (tropicalFourierTransform f ω₂) := by
  -- Proof: f̂((1-t)ω₁ + tω₂) = inf_x [f(x) + ⟨(1-t)ω₁+tω₂, x⟩]
  --       = inf_x [f(x) + (1-t)⟨ω₁,x⟩ + t⟨ω₂,x⟩]
  --       ≤ max(inf_x [f(x) + ⟨ω₁,x⟩], inf_x [f(x) + ⟨ω₂,x⟩])
  --       = max(f̂(ω₁), f̂(ω₂))
  sorry
```

### Theorem 9: tropical_fourier_spectrum_cardinality_bound
```lean
/-- Lower bound on tropical spectrum size: a function with d-dimensional
    essential time support must have at least d-dimensional frequency support.
    Bridge: connects dimension theory to harmonic analysis.
    Application: minimal_frequency_complexity for adversarial_detection. -/
theorem tropical_fourier_spectrum_cardinality_bound {n : ℕ}
    {f : (Fin n → ℝ) → EReal}
    (hf_proper : ∃ x, f x < ⊤)
    (hf_lsc : ∀ a, IsClosed {x | a ≤ f x})
    (hf_tconvex : ∀ x y t, f ((1-t)•x + t•y) ≤ max (f x) (f y))
    (h_dim : (tropicalSpectrum f).encard = d) :
    (tropicalSpectrum (tropicalFourierTransform f)).encard ≥ n - d + 1 := by
  -- Proof: By tropical uncertainty principle, |supp(f)| · |supp(f̂)| ≥ n
  -- So |supp(f̂)| ≥ n/d = n/(n - (n-d)) ≥ n - d + 1
  sorry
```

### Theorem 10: tropical_fourier_sharp_uncertainty
```lean
/-- SHARP TROPICAL UNCERTAINTY: The uncertainty bound is tight —
    delta functions achieve equality: |supp(δ_x)| · |supp(δ̂_x)| = 1 · n = n.
    Bridge: connects extremal combinatorics to harmonic analysis.
    Application: sharp_certified_robustness_bound for adversarial examples. -/
theorem tropical_fourier_sharp_uncertainty {n : ℕ} (x₀ : Fin n → ℝ) :
    let f : (Fin n → ℝ) → EReal := fun x => if x = x₀ then (0 : ℝ) else ⊤
    (tropicalSpectrum f).encard = 1 ∧
    (tropicalSpectrum (tropicalFourierTransform f)).encard = n := by
  -- Proof: δ_{x₀} has support {x₀}, and f̂(ω) = ⟨ω, x₀⟩ which has
  -- full support (since ⟨ω, x₀⟩ varies over all reals)
  sorry
```

### Theorem 11: min_plus_dft_matrix_tropical_rank
```lean
/-- The min-plus DFT matrix has full tropical rank n.
    Bridge: connects tropical linear algebra to spectral theory.
    Application: post_quantum_lattice_reduction via tropical determinants. -/
theorem minPlusDFT_matrix_tropical_rank (n : ℕ) (hn : 0 < n) :
    tropicalRank (minPlusDFTMatrix n) = n := by
  -- Proof: The min-plus DFT matrix has tropical determinant (min-plus permanent)
  -- equal to n · (n-1)/2 ≠ ⊤, so it has full tropical rank.
  sorry
```

---

## PROOF ARCHITECTURE

The theorems form a coherent dependency graph:

```
tropical_fourier_young_inequality (Theorem 1)
    ↓
tropical_fourier_double_conjugate_lower_bound (Theorem 2)
    ↓
tropical_fourier_inversion (Theorem 3)  ←── Hahn-Banach separation
    ↓                          ↓
idempotent_parseval_identity    tropical_convex_preserved (Theorem 8)
(Theorem 4)                         ↓
    ↓                           tropical_fourier_spectrum_bound (Theorem 9)
idempotent_parseval_discrete         ↓
(Theorem 5)                     tropical_uncertainty_principle (Theorem 6)
    ↓                               ↓
tropical_fourier_sharp_uncertainty (Theorem 10)
```

**Key Lemma Chain for Theorem 3 (Fenchel-Moreau)**:
1. `tropical_fourier_young_inequality`: f(x) + f̂(ω) ≥ ⟨ω,x⟩
2. `double_conjugate_lower_bound`: f ≤ f̂̂ (from Young by taking inf over ω)
3. `epigraph_closed_convex`: epi(f) is closed convex when f is lsc convex
4. `separating_hyperplane_exists`: For (x₀, α) ∉ epi(f), ∃ separating (ω, -1)
5. `separating_hyperplane_witnesses_upper_bound`: f̂(ω) + ⟨ω,x₀⟩ ≤ α < f(x₀)
6. `contradiction_with_lower_bound`: f̂̂(x₀) < f(x₀) contradicts f ≤ f̂̂

---

## CROSS-DOMAIN BRIDGES

1. **Tropical Harmonic Analysis ↔ Convex Optimization**: The Fenchel-Moreau theorem IS tropical Fourier inversion. Every convex duality result is a tropical spectral theorem. (Bridge: connects `Algebra.coordinateRing` to `Tropical.tropicalConvex`)

2. **Tropical Harmonic Analysis ↔ Quantum Mechanics**: Maslov's idempotent analysis shows that ℏ→0 limits of Feynman path integrals give min-plus integrals. The tropical Fourier transform is the classical (ℏ→0) limit of the quantum Fourier transform. (Bridge: connects `Physics.quantum` to `Tropical.minPlusSemiring`)

3. **Tropical Uncertainty ↔ Certified Robustness**: The tropical uncertainty principle |supp(f)|·|supp(f̂)| ≥ d gives a fundamental lower bound on the size of adversarial perturbations that can fool a tropical neural network. If a network's decision boundary has tropical spectrum size k, then any adversarial example must have time-domain support size ≥ d/k. (Bridge: connects `EML.idempotentSemiring` to cryptographic `certified_robustness`)

4. **Min-Plus DFT ↔ Post-Quantum Lattice Cryptography**: The min-plus DFT matrix has full tropical rank, enabling tropical spectral methods for lattice problems. The tropical uncertainty principle limits the information an adversary can extract about lattice points from tropical frequency observations. (Bridge: connects `Bridges.valuationStabilizer` to `Cryptography`)

---

## COMPUTATIONAL BOUNDS

```lean
/-- The tropical Fourier transform can be computed in O(n²) time for
    n-dimensional functions on finite domains. This is the tropical
    analogue of the O(n log n) FFT. -/
theorem tropical_fourier_transform_complexity {n : ℕ} :
    ∃ f : (Fin n → ℝ) → EReal,
    computation_bound (tropicalFourierTransform f) = O(n^2) := by
  -- Each f̂(ω) requires O(n) operations, and there are n values of ω
  sorry

/-- The tropical uncertainty bound is tight: there exist functions
    achieving |supp(f)| · |supp(f̂)| = n (delta functions).
    This gives Omega(n) as a lower bound on the product of support sizes. -/
theorem tropical_uncertainty_tight_bound {n : ℕ} :
    ∃ f : (Fin n → ℝ) → EReal,
    (tropicalSpectrum f).encard * (tropicalSpectrum (tropicalFourierTransform f)).encard = n := by
  -- Witness: delta function at any point
  sorry

/-- Lipschitz bound for tropical Fourier transform: if f is L-Lipschitz,
    then f̂ is L-Lipschitz in the frequency domain.
    Application: lipschitz_certified_robustness for tropical neural networks. -/
theorem tropical_fourier_lipschitz_bound {n : ℕ} {f : (Fin n → ℝ) → EReal} {L : ℝ}
    (hf_lipschitz : LipschitzWith L f) :
    LipschitzWith L (tropicalFourierTransform f) := by
  -- Proof: |f̂(ω₁) - f̂(ω₂)| ≤ L‖ω₁ - ω₂‖ by Lipschitz property of f
  sorry
```

---

## REQUIRED TACTIC DIVERSITY

Every theorem must use diverse tactics. Required tactic distribution:
- **`induction`**: For discrete Parseval and uncertainty over `Fin n`
- **`rcases`**: For case analysis on `EReal` values (finite, +∞, -∞)
- **`by_contra`**: For uncertainty principle (contradiction from |S|·|T| < n)
- **`omega`/`linarith`**: For arithmetic bounds in uncertainty and Parseval
- **`field_simp`**: For inner product manipulations in Young's inequality
- **`conv`/`simp`**: For unfolding definitions of tropical Fourier transform
- **`exact`/`apply`**: For composing lemmas in the Fenchel-Moreau chain
- **`have`/`obtain`**: For constructing separating hyperplanes

---

## FUTURE_DIRECTIONS

Aristotle MUST produce a structured `FUTURE_DIRECTIONS.md` with these concrete next steps:

1. **Tropical FFT Algorithm**: Formalize an O(n²) tropical FFT and prove its correctness. This enables efficient tropical spectral methods for certified robustness.

2. **Tropical Shannon Entropy**: Define tropical entropy H_trop(f) = -inf_x [f(x) + log(f(x))] and prove the tropical data processing inequality, connecting to information theory and differential privacy.

3. **Tropical Wiener-Khinchin Theorem**: Prove that the tropical autocorrelation's Fourier transform is the tropical power spectrum, enabling tropical spectral analysis of time series.

4. **Tropical Heisenberg Group**: Formalize the min-plus Heisenberg group and prove that tropical uncertainty is invariant under tropical time-frequency shifts, connecting to quantum mechanics.

5. **Post-Quantum Applications**: Use tropical uncertainty to prove security bounds for lattice-based cryptosystems against min-plus spectral attacks, advancing post-quantum cryptography.

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
            Open the field of min-plus (tropical) harmonic analysis by proving three foundational theorems that establish the Legendre-Fenchel transform as the natural Fourier transform in the idempotent setting and develop the corresponding spectral theory with uncertainty principles. Theorem 1 (Tropical Fourier Inversion): For any lower semicontinuous tropically convex function f on a finite-dimensional min-plus semimodule V, the double Legendre-Fenchel transform recovers f, i.e., f**(x) = sup_omega [f_hat(omega) - <omega, x>] = f(x), establishing tropical Fourier inversion analogous to the classical inversion formula. Theorem 2 (Idempotent Parseval Identity): The infimum of a tropical function equals the infimum of its tropical Fourier transform, i.e., inf_x f(x) = inf_omega f_hat(omega), establishing idempotent energy conservation under the min-plus Fourier transform. Theorem 3 (Tropical Uncertainty Principle): For any tropical function f on a finite semimodule of dimension d, the product of tropical essential supports satisfies |essSupp(f)| * |essSupp(f_hat)| >= d, establishing a fundamental limit on simultaneous time-frequency localization in the min-plus setting. These results reveal the Legendre-Fenchel transform as the Fourier transform of tropical mathematics, creating a new field at the intersection of idempotent analysis, convex optimization, and harmonic analysis with direct applications to scheduling theory, network calculus, and tropical neural networks.

            ### Precise Mathematical Framing
            Let R_min = (R union {+infty}, min, +) be the min-plus semiring. For a function f: V -> R_min on a finite semimodule V over R_min, define the tropical Fourier transform (Legendre-Fenchel conjugate) as f_hat(omega) = inf_{x in V} [f(x) + <omega, x>] where <.,.> is the canonical semimodule pairing. The inverse tropical Fourier transform is the double conjugate f**(x) = sup_omega [f_hat(omega) - <omega, x>]. Tropical Fourier Inversion: For f tropically convex and lower semicontinuous, f** = f. Idempotent Parseval: inf f = inf f_hat follows from the inf-preserving property of the Legendre-Fenchel transform and the Galois connection structure. Tropical Uncertainty: Define essSupp_eps(f) = {x : f(x) < inf f + eps} for appropriate eps; then |essSupp(f)| * |essSupp(f_hat)| >= dim(V) via a dimension-counting argument on the support hyperplanes of the tropical polyhedron defined by f. Key technical tools: (1) the Galois connection between a semimodule and its tropical dual, (2) the tropical Farkas lemma for support functions, (3) the structure theory of tropical polyhedra as finite intersections of tropical half-spaces.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_plus_distributes_over_min` : theorem tropical_plus_distributes_over_min (a b c : ℝ) :
     (file: Bridges/MinPlusVerificationCore.lean)
  2. `pair_margin_lower_bound_under_perturbation` : lemma pair_margin_lower_bound_under_perturbation
     (file: Bridges/GL3TopCycleRobustness.lean)
  3. `tropical_lattice_dimension_bound` : theorem tropical_lattice_dimension_bound (n : ℕ) (hn : 8 ≤ n) :
     (file: Bridges/ProofAlgGeomBridge.lean)
  4. `tropical_max_idempotent` : theorem tropical_max_idempotent (x : ℝ) : max x x = x := max_self x
     (file: Bridges/BreakthroughDirections.lean)
  5. `analysis_bridge_unique_limit` : theorem analysis_bridge_unique_limit {X : Type*} [TopologicalSpace X] [T2Space X]
     (file: Bridges/CategoricalBridges.lean)

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



Recent successful concepts: Idempotent Measure Theory: Min-Plus Choquet-Radon Representation, Idempotent Lebesgue Decomposition, and Tropical Kernel Representer Certification, Ideal-Theoretic Learning Capacity: Hilbert-VC Dimension Correspondence, Localization Generalization Bounds, and Noetherian Feature Convergence, Algebraic Circuit Complexity: Ideal-Theoretic Polynomial Identity Testing, Coordinate Ring Depth Bounds, and Gröbner Derandomization


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician, software engineer, and science writer.
            Create ALL of the following:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **ARTICLE.md** — MANDATORY standalone popular-science article
               CRITICAL RULES:
               • Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
               • Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
               • This is a premier magazine-quality piece for curious, intelligent readers.
               QUALITY STANDARDS:
               • Superb, vivid, engaging prose with a strong opening hook and narrative arc.
               • Concrete analogies and metaphors that make abstract ideas tangible.
               • Story structure: provocative question → tension → breakthrough → significance.
               • Real-world connections: technology, nature, everyday life.
               • Historical context: place the work in the sweep of intellectual history.
               • 1500–3000 words. Substantial, standalone, enjoyable, interesting.
               • A reader should say "Wow, I had no idea math could do THAT."

            3. **RESEARCH_PAPER.md** — MANDATORY comprehensive, in-depth research paper
               This is a full, publishable-quality paper, NOT a summary:
               • Abstract, Introduction, Definitions & Notation
               • Main Results with detailed proof sketches (not just "by induction")
               • Algorithms with complete pseudocode and complexity analysis
               • Applications with worked examples showing practical use
               • Computational Experiments with tables, charts, numerical results
               • Discussion, Future Work, References
               • 3000–8000 words. Thorough and substantive.

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale

               ## Under-explored Territory
               ## Cross-Domain Bridges
               ## Open Problems Encountered

            5. **Python code** — demos, visualizations, algorithms, applications:
               - **demo.py** — concrete numerical examples bringing the math to life
               - **visualizations** — matplotlib/plotly charts (save as PNG/SVG too)
               - **algorithms.py** — implement algorithms from the paper with docstrings
               - **applications.py** — real-world applications (ML, crypto, physics)

            6. **diagram.svg** — visualization of key mathematical structures

            7. **PACKAGE.html** — MANDATORY standalone HTML package
               Bundle ALL artifacts into a single, self-contained HTML file:
               • Everything inlined (CSS, JS, content). No external dependencies.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


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
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — Standalone HTML Package  →  PACKAGE.html
────────────────────────────────────────────────────────────────────────────
Create a **single, self-contained HTML file** that bundles ALL artifacts
into a beautiful, interactive presentation. Requirements:

• **Single file**: Everything (CSS, JS, content) inlined. No external deps.
• **Navigation**: Sidebar or tab navigation between sections:
  - Article (the popular-science piece)
  - Research Paper (the full paper)
  - Interactive Demos (embedded Python output / JS visualizations)
  - Algorithms (pseudocode + implementation)
  - Visualizations (embedded charts/diagrams as inline SVG or base64)
  - Code Listings (syntax-highlighted Python and proof code)
• **Beautiful design**: Modern, clean typography (system fonts).
  Dark/light mode toggle. Responsive layout. Smooth transitions.
• **Math rendering**: Use KaTeX (CDN link OK for math rendering only)
  for any mathematical notation.
• **Syntax highlighting**: Inline code highlighting for Python blocks.
• **Interactive elements**: Collapsible sections, smooth scroll, TOC.
• The HTML package should work when opened directly in any browser.
• Include ALL content from the article, research paper, and code.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: formalize
